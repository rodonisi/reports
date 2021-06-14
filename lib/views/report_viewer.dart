// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/logger.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/models/reports.dart';
import 'package:reports/widgets/app_bar_text_field.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - ReportViewer Widget Declaration
// -----------------------------------------------------------------------------
class ReportViewerArgs {
  ReportViewerArgs({required this.report, this.index});

  final Report report;
  final int? index;
}

class ReportViewer extends StatefulWidget {
  ReportViewer({Key? key}) : super(key: key);

  static const String routeName = '/report_viewer';

  @override
  _ReportViewerState createState() => _ReportViewerState();
}

class _ReportViewerState extends State<ReportViewer> {
  final _controllers = <TextEditingController>[];

  void _setStateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _args =
        ModalRoute.of(context)!.settings.arguments as ReportViewerArgs;

    final isNew = _args.index == null;
    final report = _args.report;
    final titleController = TextEditingController.fromValue(
      TextEditingValue(
        text: report.title,
      ),
    );

    _controllers.addAll(List.generate(
        report.layout.fields.length, (index) => TextEditingController()));

    for (var i = 0; i < report.data.length; i++) {
      _controllers[i].text = report.data[i].text;
    }

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
              return _FormCard(
                options: report.layout.fields[i],
                controller: _controllers[i],
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
                  controllers: _controllers,
                  report: report,
                  index: _args.index,
                )),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _ExportDialog Widget Declaration
// -----------------------------------------------------------------------------
class _ExportDialog extends StatelessWidget {
  const _ExportDialog({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('JSON Export'),
      content: SelectableText(text),
      actions: <Widget>[
        new TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Close',
              overflow: TextOverflow.ellipsis,
            )),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// - _FormCard Widget Declaration
// -----------------------------------------------------------------------------
class _FormCard extends StatelessWidget {
  const _FormCard({Key? key, required this.options, required this.controller})
      : super(key: key);

  final FieldOptions options;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    Widget _getField() {
      switch (options.fieldType) {
        case 0:
          return TextField(
            controller: controller,
          );
        default:
          throw ArgumentError.value(
              options.fieldType, 'unsupported field type');
      }
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(options.title), _getField()],
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
        final oldTitle = report.title;
        report.title = titleController.text;

        for (var i = 0; i < report.layout.fields.length; i++) {
          if (report.data.length <= i) {
            report.data.add(FieldData(text: controllers[i].text));
          } else {
            report.data[i].text = controllers[i].text;
          }
          logger.v('${report.layout.fields[i].title}: ${controllers[i].text}');
        }

        var reports = context.read<ReportsModel>();
        if (index != null)
          reports.update(index!, report);
        else
          reports.add(report);

        renameAndWriteFile('$reportsDirectory/$oldTitle',
            '$reportsDirectory/${report.title}', report.toJSON());

        Navigator.pop(context);
        logger.d("Saved report");
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
        .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
              child: Text(e.name),
              onTap: () => widget.report.layout = e,
              value: e.name,
            ))
        .toList();
    return DropdownButton(
        items: titleMap,
        value: widget.report.layout.name,
        onChanged: (value) => widget.refreshCallback());
  }
}
