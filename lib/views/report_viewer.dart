// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/logger.dart';
import 'package:reports/structures/report_structures.dart';
import 'package:reports/models/reports.dart';
import 'package:reports/widgets/app_bar_text_field.dart';

// -----------------------------------------------------------------------------
// - ReportViewer Widget Declaration
// -----------------------------------------------------------------------------
class ReportViewerArgs {
  ReportViewerArgs({required this.report, this.index});

  final Report report;
  final int? index;
}

class ReportViewer extends StatelessWidget {
  static const String routeName = '/report_viewer';

  ReportViewer({Key? key}) : super(key: key);

  final _controllers = <TextEditingController>[];

  @override
  Widget build(BuildContext context) {
    final _args =
        ModalRoute.of(context)!.settings.arguments as ReportViewerArgs;

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
    if (_args.index != null)
      shareAction.add(
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => _ExportDialog(text: report.toJSON()));
          },
        ),
      );

    return Scaffold(
      appBar: AppBar(
        title: AppBarTextField(controller: titleController),
        actions: shareAction,
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
      content: Text(text),
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
      onPressed: () {
        final newReport = Report(
          data: [],
          layout: report.layout,
          title: titleController.text,
        );

        for (var i = 0; i < report.layout.fields.length; i++) {
          if (newReport.data.length <= i) {
            newReport.data.add(FieldData(text: controllers[i].text));
          } else {
            newReport.data[i].text = controllers[i].text;
          }
          logger
              .v('${newReport.layout.fields[i].title}: ${controllers[i].text}');
        }

        var reports = context.read<ReportsModel>();
        if (index != null)
          reports.update(index!, newReport);
        else
          reports.add(newReport);

        Navigator.pop(context);
        logger.d("Saved report");
      },
    );
  }
}
