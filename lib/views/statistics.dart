// -----------------------------------------------------------------------------
// - Packages
// ----------------------------------------------------------------------------
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/rule_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:provider/provider.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/utilities/print_utils.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/sidebar_layout.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - StatisticsList Widget Implementation
// -----------------------------------------------------------------------------

class _PathReport {
  final String path;
  final Report report;

  _PathReport({required String path, required this.report})
      : this.path = getDirectoryName(path);
}

/// Displays the list of all the layouts used in the currently stored reports
/// pointing to the respective statistics page
class StatisticsList extends StatelessWidget {
  static const String routeName = '/statistics';
  static const ValueKey valueKey = ValueKey('Statistics');

  const StatisticsList({Key? key}) : super(key: key);

  // Read and groups reports per layout.
  Map<String, List<_PathReport>> getReportsPerLayout(BuildContext context) {
    final reportsPerLayout = <String, List<_PathReport>>{};
    final reportsFiles = getReportsList(context);

    for (final reportFile in reportsFiles) {
      final report = Report.fromJSON(reportFile.readAsStringSync());
      final pathReport = _PathReport(path: reportFile.path, report: report);
      final layout = report.layout.name;

      if (reportsPerLayout.containsKey(layout)) {
        reportsPerLayout[layout]!.add(pathReport);
      } else {
        reportsPerLayout[layout] = [pathReport];
      }
    }

    return reportsPerLayout;
  }

  @override
  Widget build(BuildContext context) {
    final reportsPerLayout = getReportsPerLayout(context);
    final showDrawer =
        context.findAncestorWidgetOfExactType<SideBarLayout>() == null;

    return WrapNavigator(
      child: MaterialPage(
        key: valueKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text('keywords.capitalized.statistics').tr(),
          ),
          drawer: showDrawer ? const Drawer(child: const MenuDrawer()) : null,
          body: ListView.separated(
            itemBuilder: (context, index) {
              final layoutName = reportsPerLayout.keys.elementAt(index);
              return ListTile(
                title: Text(layoutName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        final layoutName =
                            reportsPerLayout.keys.elementAt(index);
                        return StatisticsDetail(
                          title: layoutName,
                          path: context.read<PreferencesModel>().reportsPath,
                          reports: reportsPerLayout[layoutName]!,
                        );
                      },
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) => Divider(
              height: DrawingConstants.dividerHeight,
            ),
            itemCount: reportsPerLayout.length,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - StatisticsDetail Widget Implementation
// -----------------------------------------------------------------------------
abstract class _FieldStat {
  final String type;
  dynamic value;

  _FieldStat(this.type, this.value);

  _FieldStat operator +(_FieldStat other);
  _FieldStat operator -(_FieldStat other);
  String toString();
}

class _TextFieldStat extends _FieldStat {
  _TextFieldStat(String value)
      : super(FieldTypes.textField, double.tryParse(value) ?? 0.0);

  _TextFieldStat.fromDouble(double value) : super(FieldTypes.textField, value);

  _TextFieldStat.zero() : super(FieldTypes.textField, 0.0);

  _TextFieldStat operator +(_FieldStat other) {
    if (other is _TextFieldStat) {
      return _TextFieldStat.fromDouble(value + other.value);
    } else {
      throw ArgumentError('Cannot add ${other.runtimeType} to _TextFieldStat');
    }
  }

  _TextFieldStat operator -(_FieldStat other) {
    if (other is _TextFieldStat) {
      return _TextFieldStat.fromDouble(value - other.value);
    } else {
      throw ArgumentError(
          'Cannot subtract ${other.runtimeType} from _TextFieldStat');
    }
  }

  String toString() => value.toStringAsFixed(2);
}

class _DateRangeStat extends _FieldStat {
  _DateRangeStat({required DateTime start, required DateTime end})
      : super(FieldTypes.dateRange, end.difference(start));

  _DateRangeStat.fromDuration(Duration duration)
      : super(FieldTypes.dateRange, duration);

  _DateRangeStat.zero() : super(FieldTypes.dateRange, Duration.zero);

  _DateRangeStat operator +(_FieldStat other) {
    if (other is _DateRangeStat) {
      return _DateRangeStat.fromDuration(value + other.value);
    } else {
      throw ArgumentError('Cannot add ${other.runtimeType} to _DateRangeStat');
    }
  }

  _DateRangeStat operator -(_FieldStat other) {
    if (other is _DateRangeStat) {
      return _DateRangeStat.fromDuration(value - other.value);
    } else {
      throw ArgumentError(
          'Cannot subtract ${other.runtimeType} from _DateRangeStat');
    }
  }

  String toString() => prettyDuration(value);
}

/// Displays the statistics for the given layout, based on all local reports
/// using that layout.
class StatisticsDetail extends StatelessWidget {
  const StatisticsDetail({
    Key? key,
    required this.title,
    required this.path,
    required this.reports,
  }) : super(key: key);

  final String title;
  final String path;
  final List<_PathReport> reports;

  // Filter the list of reports for the current directory, recursive.
  List<_PathReport> _getReportsForDirectory() {
    return reports.where((report) => report.path.contains(path)).toList();
  }

  List<int> _getFilteredReportFieldsIndices(Report report, {Rule? rule}) {
    final fields = report.layout.fields;
    final filteredFields = <int>[];

    // Iterate over all the fields contained in the report.
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      // Add the index if the field's include toggle is on.
      if (field is StatisticsFieldOptions && field.statisticsInclude) {
        if (rule == null || rule.fieldType == field.fieldType) {
          filteredFields.add(i);
        }
      }
    }

    return filteredFields;
  }

  // Get the totals for each field of the given reports.
  Map<String, _FieldStat> _getFieldStats(List<_PathReport> reports) {
    final stats = <String, _FieldStat>{};

    for (final report in reports) {
      final indices = _getFilteredReportFieldsIndices(report.report);
      for (final i in indices) {
        final field = report.report.layout.fields[i];

        if (field.fieldType == FieldTypes.dateRange) {
          final data = report.report.data[i] as DateRangeFieldData;
          final duration = _DateRangeStat(start: data.start, end: data.end);

          if (stats.containsKey(field.title)) {
            stats[field.title] = stats[field.title]! + duration;
          } else {
            stats[field.title] = duration;
          }
        } else if (field.fieldType == FieldTypes.textField &&
            (field as TextFieldOptions).numeric) {
          final data = report.report.data[i] as TextFieldData;
          final value = _TextFieldStat(data.data);

          if (stats.containsKey(field.title)) {
            stats[field.title] = stats[field.title]! + value;
          } else {
            stats[field.title] = value;
          }
        }
      }
    }

    return stats;
  }

  // Get the totals for each field  type of the given reports
  Map<String, _FieldStat> _getTypeStats(List<_PathReport> reports) {
    final stats = <String, _FieldStat>{};

    for (final report in reports) {
      final indices = _getFilteredReportFieldsIndices(report.report);
      for (final i in indices) {
        final field = report.report.layout.fields[i];
        final prettyType = prettyFieldType(field.fieldType);

        if (field.fieldType == FieldTypes.dateRange) {
          final data = report.report.data[i] as DateRangeFieldData;
          final duration = _DateRangeStat(start: data.start, end: data.end);

          if (stats.containsKey(prettyType)) {
            stats[prettyType] = stats[prettyType]! + duration;
          } else {
            stats[prettyType] = duration;
          }
        } else if (field.fieldType == FieldTypes.textField &&
            (field as TextFieldOptions).numeric) {
          final data = report.report.data[i] as TextFieldData;
          final value = _TextFieldStat(data.data);

          if (stats.containsKey(prettyType)) {
            stats[prettyType] = stats[prettyType]! + value;
          } else {
            stats[prettyType] = value;
          }
        }
      }
    }

    return stats;
  }

  // Get the totals for each custom rule for the given reports.
  Map<String, _FieldStat> _getRulesStats(
      BuildContext context, List<_PathReport> reports) {
    final stats = <String, _FieldStat>{};
    final rules = getStatsRules(context);

    for (final report in reports) {
      // Iterate over the rules.
      for (final rule in rules) {
        final indices =
            _getFilteredReportFieldsIndices(report.report, rule: rule);

        final dynamic threshold;
        if (rule.fieldType == FieldTypes.textField) {
          threshold = rule.threshold!;
        } else {
          if (rule.threshold is double) {
            threshold = Duration(minutes: (60 * rule.threshold!).toInt());
          } else {
            threshold = [
              Duration(minutes: (60 * rule.threshold[0]).toInt()),
              Duration(minutes: (60 * rule.threshold[1]).toInt()),
            ];
          }
        }

        if (!rule.perField) {
          _FieldStat total = _getZeroStat(rule);
          for (final i in indices) {
            total += _getFieldStat(report.report.data[i]);
          }

          total = _adjustStat(rule, total, threshold);

          _storeStat(stats, rule, total);
        } else {
          // Scan the fields for the given rule.
          for (final i in indices) {
            _FieldStat stat = _getFieldStat(report.report.data[i]);

            stat = _adjustStat(rule, stat, threshold);

            _storeStat(stats, rule, stat);
          }
        }
      }
    }

    return stats;
  }

  _FieldStat _getFieldStat(FieldData data) {
    _FieldStat stat;
    if (data is TextFieldData) {
      stat = _TextFieldStat(data.data);
    } else {
      data as DateRangeFieldData;
      stat = _DateRangeStat(start: data.start, end: data.end);
    }
    return stat;
  }

  void _storeStat(Map<String, _FieldStat> stats, Rule rule, _FieldStat stat) {
    if (stats.containsKey(rule.name)) {
      stats[rule.name] = stats[rule.name]! + stat;
    } else {
      stats[rule.name] = stat;
    }
  }

  _FieldStat _adjustStat(Rule rule, _FieldStat stat, threshold) {
    if (rule.operationFunction(stat.value, threshold)) {
      stat.value = rule.adjustmentFunction(stat.value, threshold);
    } else {
      stat = _getZeroStat(rule);
    }
    return stat;
  }

  _FieldStat _getZeroStat(Rule rule) => rule.fieldType == FieldTypes.textField
      ? _TextFieldStat.zero()
      : _DateRangeStat.zero();

  // Get the directories in which the given reports are stored.
  Set<String> _getDirectories(List<_PathReport> reports) {
    final directories = <String>{};

    for (final report in reports) {
      final directory = getRelativePath(report.path, from: path);
      if (directory.isNotEmpty && directory != '.') {
        directories.add(directory);
      }
    }

    return directories;
  }

  // Generate cards in a wrap for each duration in the given map
  Widget _generateWrap(BuildContext context, Map<String, _FieldStat> stats,
      {bool showType = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            children: stats.entries.map(
              (element) {
                return Card(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth / 3,
                      minWidth: screenWidth / 10,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(DrawingConstants.smallPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(element.key,
                              style: DrawingConstants.boldTextStyle),
                          if (showType)
                            Text(
                              prettyFieldType(element.value.type),
                              style: DrawingConstants.secondaryTextStyle,
                            ),
                          SizedBox(
                            height: DrawingConstants.mediumPadding,
                          ),
                          Text(element.value.toString()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  // Generate a ListTile for each directory in which a report is stored.
  List<Widget> _generateDirectoryTiles(
      BuildContext context, Set<String> directories) {
    final tiles = <Widget>[];
    tiles.addAll(
      directories
          .map(
            (e) => ListTile(
              title: Text(e),
              leading: Icon(Icons.folder),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return StatisticsDetail(
                        title: title,
                        path: joinAndSetExtension(path, e, extension: ''),
                        reports: reports,
                      );
                    },
                  ),
                );
              },
            ),
          )
          .toList(),
    );

    // Insert dividers.
    for (int i = tiles.length; i >= 0; i--) {
      tiles.insert(i, Divider(height: DrawingConstants.dividerHeight));
    }

    return tiles;
  }

  // Generate a representation of the current path.
  List<Widget> getPathElements(BuildContext context) {
    final elements = <Widget>[];
    final reportsPath = context.read<PreferencesModel>().reportsPath;
    final relativePath = getRelativePath(path, from: reportsPath);

    if (relativePath.isNotEmpty && relativePath != '.') {
      final pathElements = splitPathElements(relativePath);

      elements.addAll(pathElements
          .map((e) => Text(e, style: DrawingConstants.secondaryTextStyle)));

      for (int i = elements.length - 1; i > 0; i--) {
        elements.insert(
            i,
            Icon(
              Icons.arrow_right,
              color: Colors.grey,
            ));
      }
    }

    return elements;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();
    final filteredReports = _getReportsForDirectory();
    final Map<String, _FieldStat> fieldStats =
        prefs.showFieldStatistics ? _getFieldStats(filteredReports) : {};
    final Map<String, _FieldStat> typeStats =
        prefs.showFieldTypeStatistics ? _getTypeStats(filteredReports) : {};
    final Map<String, _FieldStat> rulesStats = prefs.showCustomRuleStatistitcs
        ? _getRulesStats(context, filteredReports)
        : {};
    final directories = _getDirectories(filteredReports);
    final pathElements = getPathElements(context);

    // Don't show the stats layout if there are no statistics to be generated
    // for the given layout.
    final hasStats =
        fieldStats.isNotEmpty || typeStats.isNotEmpty || rulesStats.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: pathElements.isEmpty
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(DrawingConstants.mediumPadding),
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: DrawingConstants.smallPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: pathElements,
                  ),
                ),
              ),
      ),
      body: hasStats
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fieldStats.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.all(DrawingConstants.smallPadding),
                      child: Text(
                        'keywords.capitalized.fields',
                        style: DrawingConstants.boldTextStyle,
                      ).tr(),
                    ),
                    _generateWrap(context, fieldStats, showType: true),
                  ],
                  if (typeStats.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.all(DrawingConstants.smallPadding),
                      child: Text(
                        'keywords.capitalized.types',
                        style: DrawingConstants.boldTextStyle,
                      ).tr(),
                    ),
                    _generateWrap(context, typeStats),
                  ],
                  if (rulesStats.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.all(DrawingConstants.smallPadding),
                      child: Text(
                        'settings.statistics.custom_rules',
                        style: DrawingConstants.boldTextStyle,
                      ).tr(),
                    ),
                    _generateWrap(context, rulesStats, showType: true),
                  ],
                  if (directories.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.all(DrawingConstants.smallPadding),
                      child: Text(
                        'keywords.capitalized.directories',
                        style: DrawingConstants.boldTextStyle,
                      ).tr(),
                    ),
                    ..._generateDirectoryTiles(context, directories),
                  ],
                ],
              ),
            )
          : Center(
              child: Text('statistics.no_stats').tr(),
            ),
    );
  }
}
