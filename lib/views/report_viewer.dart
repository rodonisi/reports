// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/dropbox_utils.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/preferences.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/models/reports.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/form_tile.dart';
import 'package:reports/widgets/save_button.dart';

// -----------------------------------------------------------------------------
// - ReportViewerArgs Class Implementation
// -----------------------------------------------------------------------------

/// Arguments class for the report viewer.
class ReportViewerArgs {
  ReportViewerArgs({required this.name, this.index});

  final String name;
  final int? index;
}

// -----------------------------------------------------------------------------
// - ReportViewer Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the report viewer for a new or existing report.
class ReportViewer extends StatefulWidget {
  static const String routeName = '/report_viewer';

  final ReportViewerArgs args;
  ReportViewer({Key? key, required this.args}) : super(key: key);

  @override
  _ReportViewerState createState() => _ReportViewerState();
}

class _ReportViewerState extends State<ReportViewer> {
  late Report report;

  // Keep track of when the report file has been read.
  bool loaded = false;

  // Store the old title to determine whether it has been updated.
  late String _oldTitle;

  @override
  void initState() {
    // Read the report from file
    final futureReport = readNamedReport(widget.args.name);

    // Add completition callback for when the file has been read.
    futureReport.then((value) {
      setState(() {
        report = Report.fromJSON(value);
        _oldTitle = report.title;
        loaded = true;
      });
    }).catchError((error, stackTrace) async {
      final layoutProvider = context.read<LayoutsModel>();

      // Read the first available layout.
      final layoutString = await readNamedLayout(layoutProvider.layouts[0]);
      final defaultName =
          await Preferences.getDefaultName(DefaultNameType.report);
      setState(() {
        report = Report(
          title: defaultName,
          layout: ReportLayout.fromJSON(layoutString),
          data: [],
        );
        _oldTitle = report.title;
        loaded = true;
      });
    });

    super.initState();
  }

  void _initializeData() {
    if (report.data.length < report.layout.fields.length) {
      for (var element in report.layout.fields) {
        switch (element.fieldType) {
          case FieldTypes.date:
            report.data.add(DateFieldData(data: DateTime.now()));
            break;
          default:
            report.data.add(TextFieldData(data: ''));
        }
      }
    }
  }

  void _reinitializeData() {
    setState(() {
      report.data.clear();
      _initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the report file is not available yet, just display a progress
    // indicator.
    if (!loaded)
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );

    // Initialize the data structures if not present.
    _initializeData();

    // Determine whether we're viewing an existing report or creating a new one.
    final isNew = widget.args.index == null;

    // Add a share action if we're viewing an existing report.
    final List<Widget> shareAction = [];
    if (!isNew)
      shareAction.add(
        IconButton(
          icon: Icon(Icons.adaptive.share),
          onPressed: () async {
            final reportsDir = await getReportsDirectory;
            Share.shareFiles(['$reportsDir/${report.title}.json']);
          },
        ),
      );

    return Scaffold(
      appBar: AppBar(
        title: ControlledTextField(
          decoration: InputDecoration(border: InputBorder.none),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          hasClearButton: true,
          maxLines: 1,
          initialValue: report.title,
          onChanged: (value) => report.title = value,
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          color: Colors.red,
          onPressed: () => Navigator.pop(context),
        ),
        actions: shareAction,
        bottom: isNew
            ? PreferredSize(
                preferredSize: Size(0.0, 30.0),
                child: _LayoutSelector(
                  report: report,
                  refreshCallback: _reinitializeData,
                ),
              )
            : null,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
        itemCount: report.layout.fields.length,
        itemBuilder: (context, i) {
          return _FormViewerCard(
            options: report.layout.fields[i],
            data: report.data[i],
          );
        },
      ),
      bottomNavigationBar: SaveButton(onPressed: _saveReport),
    );
  }

  void _saveReport() async {
    final prefs = await SharedPreferences.getInstance();

    // Update or add the report in the provider.
    var reportsProvider = context.read<ReportsModel>();
    if (widget.args.index != null)
      reportsProvider.update(widget.args.index!, report);
    else
      reportsProvider.add(report.title);

    // Write the report to file.
    final file = renameAndWriteFile('$reportsDirectory/$_oldTitle',
        '$reportsDirectory/${report.title}', report.toJSON());

    // Backup the newly created file to dropbox if option is enabled.
    final dbEnabled = prefs.getBool(Preferences.dropboxEnabled);
    if (dbEnabled != null && dbEnabled) {
      // Wait for the file to be written
      await file;
      // Backup to dropbox.
      dbBackupFile('${report.title}.json', reportsDirectory);
    }

    Navigator.pop(context);
  }
}

// -----------------------------------------------------------------------------
// - _FormViewerCard Widget Declaration
// -----------------------------------------------------------------------------
class _FormViewerCard extends StatelessWidget {
  const _FormViewerCard({
    Key? key,
    required this.options,
    required this.data,
  }) : super(key: key);

  final FieldOptions options;
  final FieldData data;

  @override
  Widget build(BuildContext context) {
    if (options is SectionFieldOptions)
      return FormTileContent(
        options: options,
        enabled: false,
      );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: FormTileContent(
                options: options,
                data: data,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _LayoutSelector Widget Implementation
// -----------------------------------------------------------------------------

class _LayoutSelector extends StatefulWidget {
  _LayoutSelector(
      {Key? key, required this.report, required this.refreshCallback})
      : super(key: key);

  final Report report;
  final refreshCallback;

  @override
  __LayoutSelectorState createState() => __LayoutSelectorState();
}

class __LayoutSelectorState extends State<_LayoutSelector> {
  @override
  Widget build(BuildContext context) {
    var layoutsProvider = context.watch<LayoutsModel>();
    var titleMap = layoutsProvider.layouts
        .map<DropdownMenuItem<String>>(
          (e) => DropdownMenuItem<String>(
            child: Text(e),
            value: e,
          ),
        )
        .toList();
    return DropdownButton<String>(
        items: titleMap,
        value: widget.report.layout.name,
        onChanged: (value) async {
          // Load layout.
          final layoutString = await readNamedLayout(value!);
          // Update layout.
          widget.report.layout = ReportLayout.fromJSON(layoutString);
          // Refresh parent widget.
          widget.refreshCallback();
        });
  }
}
