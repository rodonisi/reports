// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/dropbox_utils.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/common/report_structures.dart';
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
      final localizations = AppLocalizations.of(context)!;
      final layouts = getLayoutsList(context);
      // Read the first available layout.
      final layoutString = await layouts.first.readAsString();

      final prefs = context.read<PreferencesModel>();
      prefs.initializeString(
          PreferenceKeys.reportBaseName, localizations.report);
      final defaultName = prefs.defaultReportName;
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

    final prefs = context.read<PreferencesModel>();

    // Add a share action if we're viewing an existing report.
    final List<Widget> shareAction = [];
    if (!_isNew)
      shareAction.add(
        IconButton(
          icon: Icon(Icons.adaptive.share),
          onPressed: () {
            Share.shareFiles(
                [joinAndSetExtension(prefs.reportsPath, report.title)]);
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
    final localizations = AppLocalizations.of(context)!;

    final reportString = await report.toJSON();
    var destPath = '';
    var fromPath = '';

    if (_isNew) {
      destPath = joinAndSetExtension(widget.args.path, report.title);
    } else {
      destPath = joinAndSetExtension(p.dirname(widget.args.path), report.title);
      if (destPath != widget.args.path) fromPath = widget.args.path;
    }

    // Write the report to file.
    final didWrite = await writeToFile(reportString, destPath,
        checkExisting: destPath != widget.args.path, renameFrom: fromPath);
    if (!didWrite) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(localizations.fileExists(localizations.report)),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Backup the newly created file to dropbox if option is enabled.
    if (context.read<PreferencesModel>().dropboxEnabled) {
      // Backup to dropbox.
      dbBackupFile(context, destPath);
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

  @override
  void initState() {
    super.initState();

    final layoutsList = getLayoutsList(context);

    // Set the default layout.
    _selectedLayout = layoutsList.first;

    // Generate the list of dropdown menu items.
    _menuItems = layoutsList
        .map<DropdownMenuItem<File>>((element) => DropdownMenuItem(
              child: Text(p.basenameWithoutExtension(element.path)),
              value: element,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
