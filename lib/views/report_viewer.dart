// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/dropbox_utils.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/preferences.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/form_tile.dart';
import 'package:reports/widgets/save_button.dart';

// -----------------------------------------------------------------------------
// - ReportViewerArgs Class Implementation
// -----------------------------------------------------------------------------

/// Arguments class for the report viewer.
class ReportViewerArgs {
  ReportViewerArgs({required this.path});

  final String path;
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

  late bool _isNew;

  @override
  void initState() {
    // Read the report from file
    final futureReport = File(widget.args.path).readAsString();

    // Add completition callback for when the file has been read.
    futureReport.then((value) {
      setState(() {
        report = Report.fromJSON(value);
        loaded = true;
        _isNew = false;
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
        loaded = true;
        _isNew = true;
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
          case FieldTypes.dateRange:
            report.data.add(DateRangeFieldData.empty());
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

    // Add a share action if we're viewing an existing report.
    final List<Widget> shareAction = [];
    if (!_isNew)
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
        bottom: _isNew
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
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: SaveButton(onPressed: _saveReport),
      ),
    );
  }

  void _saveReport() async {
    final prefs = await SharedPreferences.getInstance();

    final File reportFile;
    // Write the report to file.
    if (_isNew) {
      var path = p.join(widget.args.path, report.title);
      path = p.setExtension(path, '.json');
      reportFile = File(path);
    } else {
      final file = File(widget.args.path);
      var newPath = p.join(file.parent.path, report.title);
      newPath = p.setExtension(newPath, '.json');
      reportFile = await file.rename(newPath);
    }
    await reportFile.writeAsString(await report.toJSON());

    // Backup the newly created file to dropbox if option is enabled.
    final dbEnabled = prefs.getBool(Preferences.dropboxEnabled);
    if (dbEnabled != null && dbEnabled) {
      // Get relative path from the local documents directory.
      final dir =
          p.relative(reportFile.parent.path, from: await getLocalDocsPath);

      // Backup to dropbox.
      dbBackupFile('${report.title}.json', dir);
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
  File _selectedLayout = File('');
  List<DropdownMenuItem<File>> _menuItems = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    getLayoutsList().then((value) {
      setState(() {
        // Set the default layout.
        _selectedLayout = value.first;

        // Generate the list of dropdown menu items.
        _menuItems = value
            .map<DropdownMenuItem<File>>((element) => DropdownMenuItem(
                  child: Text(p.basenameWithoutExtension(element.path)),
                  value: element,
                ))
            .toList();
      });

      // Update loaded flag.
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded)
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );

    return DropdownButton<File>(
        items: _menuItems,
        value: _selectedLayout,
        onChanged: (value) async {
          _selectedLayout = value!;
          // Read layout.
          final layoutString = await _selectedLayout.readAsString();
          // Update layout.
          widget.report.layout = ReportLayout.fromJSON(layoutString);
          // Refresh parent widget.
          widget.refreshCallback();
        });
  }
}
