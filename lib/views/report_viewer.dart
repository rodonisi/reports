// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/widgets/form_tile.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/logger.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/models/reports.dart';
import 'package:reports/widgets/app_bar_text_field.dart';

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
  final controllers = <TextEditingController>[];
  // Keep track of when the report file has been read.
  bool loaded = false;

  void _setStateCallback() {
    setState(() {});
  }

  @override
  void initState() {
    // Read the report from file
    final futureReport = readNamedReport(widget.args.name);

    // Add completition callback for when the file has been read.
    futureReport.then((value) {
      setState(() {
        report = Report.fromJSON(value);
        loaded = true;
      });
    }).catchError((error, stackTrace) async {
      final layoutProvider = context.read<LayoutsModel>();

      // Read the first available layout.
      final layoutString = await readNamedLayout(layoutProvider.layouts[0]);
      setState(() {
        report = Report(
          title: widget.args.name,
          layout: ReportLayout.fromJSON(layoutString),
          data: [],
        );
        loaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // If the report file is not available yet, just display a progrss
    // indicator.
    if (!loaded)
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );

    // Determine whether we're viewing an existing report or creating a new one.
    final isNew = widget.args.index == null;

    // Declare a controller for the tile.
    final titleController = TextEditingController.fromValue(
      TextEditingValue(
        text: report.title,
      ),
    );

    // Generate a controller for each of the fields.
    controllers.addAll(List.generate(
        report.layout.fields.length, (index) => TextEditingController()));

    // Set the controllers' text to that of the existing data.
    for (var i = 0; i < report.data.length; i++) {
      controllers[i].text = (report.data[i] as TextFieldData).data;
    }

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
        title: AppBarTextField(controller: titleController),
        actions: shareAction,
        bottom: isNew
            ? PreferredSize(
                preferredSize: Size(0.0, 30.0),
                child: _LayoutSelector(
                  report: report,
                  refreshCallback: _setStateCallback,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            itemCount: report.layout.fields.length,
            itemBuilder: (context, i) {
              return _FormViewerCard(
                options: report.layout.fields[i],
                controller: controllers[i],
              );
            },
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: _SaveButton(
                  titleController: titleController,
                  controllers: controllers,
                  report: report,
                  index: widget.args.index,
                )),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _FormViewerCard Widget Declaration
// -----------------------------------------------------------------------------
class _FormViewerCard extends StatelessWidget {
  const _FormViewerCard(
      {Key? key, required this.options, required this.controller})
      : super(key: key);

  final FieldOptions options;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: FormTileContent(
                options: options,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _SaveButton Widget Implementation
// -----------------------------------------------------------------------------
class _SaveButton extends StatelessWidget {
  _SaveButton(
      {Key? key,
      required this.titleController,
      required this.report,
      required this.controllers,
      required this.index})
      : super(key: key);
  final TextEditingController titleController;
  final Report report;
  final List<TextEditingController> controllers;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Save'),
      onPressed: () async {
        // Store the old title to determine whether it has been updated.
        final oldTitle = report.title;
        // Update the title.
        report.title = titleController.text;

        // Iterate over the fields.
        for (var i = 0; i < report.layout.fields.length; i++) {
          // Add a new entry to the data list if it does not exist.
          if (report.data.length <= i) {
            report.data.add(TextFieldData(data: controllers[i].text));
          } else {
            // Update the existing entry otherwise.
            (report.data[i] as TextFieldData).data = controllers[i].text;
          }
          logger.v('${report.layout.fields[i].title}: ${controllers[i].text}');
        }

        // Update or add the report in the provider.
        var reportsProvider = context.read<ReportsModel>();
        if (index != null)
          reportsProvider.update(index!, report);
        else
          reportsProvider.add(report.title);

        // Write the report to file.
        renameAndWriteFile('$reportsDirectory/$oldTitle',
            '$reportsDirectory/${report.title}', report.toJSON());

        Navigator.pop(context);
      },
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
