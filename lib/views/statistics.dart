// -----------------------------------------------------------------------------
// - Packages
// ----------------------------------------------------------------------------
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/common/report_structures.dart';
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
abstract class _FieldStats {
  final String type;

  _FieldStats(this.type);

  _FieldStats operator +(_FieldStats other);
  _FieldStats operator -(_FieldStats other);
  String toString();
}

class _DateRangeStats extends _FieldStats {
  final Duration duration;

  _DateRangeStats(this.duration) : super(FieldTypes.dateRange);

  _DateRangeStats operator +(_FieldStats other) {
    if (other is _DateRangeStats) {
      return _DateRangeStats(duration + other.duration);
    } else {
      throw ArgumentError('Cannot add ${other.runtimeType} to _DateRangeStats');
    }
  }

  _DateRangeStats operator -(_FieldStats other) {
    if (other is _DateRangeStats) {
      return _DateRangeStats(duration - other.duration);
    } else {
      throw ArgumentError(
          'Cannot subtract ${other.runtimeType} from _DateRangeStats');
    }
  }

  String toString() => prettyDuration(duration);
}

class _TextFieldStats extends _FieldStats {
  final double value;

  _TextFieldStats(String value)
      : value = double.tryParse(value) ?? 0.0,
        super(FieldTypes.textField);

  _TextFieldStats.fromDouble(this.value) : super(FieldTypes.textField);

  _TextFieldStats operator +(_FieldStats other) {
    if (other is _TextFieldStats) {
      return _TextFieldStats.fromDouble(value + other.value);
    } else {
      throw ArgumentError('Cannot add ${other.runtimeType} to _TextFieldStats');
    }
  }

  _TextFieldStats operator -(_FieldStats other) {
    if (other is _TextFieldStats) {
      return _TextFieldStats.fromDouble(value - other.value);
    } else {
      throw ArgumentError(
          'Cannot subtract ${other.runtimeType} from _TextFieldStats');
    }
  }

  String toString() => value.toStringAsFixed(2);
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

  List<int> _getFilteredReportFieldsIndices(Report report) {
    final fields = report.layout.fields;
    final filteredFields = <int>[];

    // Iterate over all the fields contained in the report.
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      // Add the index if the field's include toggle is on.
      if (field is StatisticsFieldOptions && field.statisticsInclude) {
        filteredFields.add(i);
      }
    }

    return filteredFields;
  }

  // Get the totals for each field of the given reports.
  Map<String, _FieldStats> _getFieldStats(List<_PathReport> reports) {
    final stats = <String, _FieldStats>{};

    for (final report in reports) {
      final indices = _getFilteredReportFieldsIndices(report.report);
      for (final i in indices) {
        final field = report.report.layout.fields[i];

        if (field.fieldType == FieldTypes.dateRange) {
          final data = report.report.data[i] as DateRangeFieldData;
          final duration = _DateRangeStats(data.end.difference(data.start));

          if (stats.containsKey(field.title)) {
            stats[field.title] = stats[field.title]! + duration;
          } else {
            stats[field.title] = duration;
          }
        } else if (field.fieldType == FieldTypes.textField &&
            (field as TextFieldOptions).numeric) {
          final data = report.report.data[i] as TextFieldData;
          final value = _TextFieldStats(data.data);

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
  Map<String, _FieldStats> _getTypeStats(List<_PathReport> reports) {
    final stats = <String, _FieldStats>{};

    for (final report in reports) {
      final indices = _getFilteredReportFieldsIndices(report.report);
      for (final i in indices) {
        final field = report.report.layout.fields[i];
        final prettyType = prettyFieldType(field.fieldType);

        if (field.fieldType == FieldTypes.dateRange) {
          final data = report.report.data[i] as DateRangeFieldData;
          final duration = _DateRangeStats(data.end.difference(data.start));

          if (stats.containsKey(prettyType)) {
            stats[prettyType] = stats[prettyType]! + duration;
          } else {
            stats[prettyType] = duration;
          }
        } else if (field.fieldType == FieldTypes.textField &&
            (field as TextFieldOptions).numeric) {
          final data = report.report.data[i] as TextFieldData;
          final value = _TextFieldStats(data.data);

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
  Map<String, _FieldStats> _getRulesStats(
      BuildContext context, List<_PathReport> reports) {
    final stats = <String, _FieldStats>{};
    final rules = getStatsRules(context);

    for (final report in reports) {
      // Iterate over the rules.
      for (final rule in rules) {
        final indices = _getFilteredReportFieldsIndices(report.report);
        // Scan the fields for the given rule.
        for (final i in indices) {
          final field = report.report.layout.fields[i];

          if (rule.fieldType == FieldTypes.dateRange &&
              field.fieldType == rule.fieldType) {
            // Handle a date range rule.
            final data = report.report.data[i] as DateRangeFieldData;
            var duration = data.end.difference(data.start);
            final dynamic threshold;
            if (rule.threshold is double) {
              threshold = Duration(minutes: (60 * rule.threshold!).toInt());
            } else {
              threshold = [
                Duration(minutes: (60 * rule.threshold[0]).toInt()),
                Duration(minutes: (60 * rule.threshold[1]).toInt()),
              ];
            }

            var stat = _DateRangeStats(Duration.zero);

            if (rule.operationFunction(duration, threshold)) {
              // Adjust the duration to the threshold.
              duration = rule.adjustmentFunction(duration, threshold);
              stat = _DateRangeStats(duration);
            }

            if (stats.containsKey(rule.name)) {
              stats[rule.name] = stats[rule.name]! + stat;
            } else {
              stats[rule.name] = stat;
            }
          } else if (rule.fieldType == FieldTypes.textField &&
              field.fieldType == rule.fieldType &&
              (field as TextFieldOptions).numeric) {
            // Handle a text field rule.
            final data = report.report.data[i] as TextFieldData;
            var value = double.tryParse(data.data) ?? 0.0;
            final threshold = rule.threshold!;

            var stat = _TextFieldStats(0.0.toString());

            if (rule.operationFunction(value, threshold)) {
              // Adjust the value to the threshold.
              value = rule.adjustmentFunction(value, threshold);
              stat = _TextFieldStats(value.toString());
            }

            if (stats.containsKey(rule.name)) {
              stats[rule.name] = stats[rule.name]! + stat;
            } else {
              stats[rule.name] = stat;
            }
          }
        }
      }
    }

    return stats;
  }

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
  Widget _generateWrap(BuildContext context, Map<String, _FieldStats> stats,
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
    final Map<String, _FieldStats> fieldStats =
        prefs.showFieldStatistics ? _getFieldStats(filteredReports) : {};
    final Map<String, _FieldStats> typeStats =
        prefs.showFieldTypeStatistics ? _getTypeStats(filteredReports) : {};
    final Map<String, _FieldStats> rulesStats = prefs.showCustomRuleStatistitcs
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
