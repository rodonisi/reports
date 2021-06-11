// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/structures/report_structures.dart';
import 'package:reports/models/reports.dart';

// -----------------------------------------------------------------------------
// - ReportViewer Widget Declaration
// -----------------------------------------------------------------------------
class ReportViewerArgs {
  ReportViewerArgs({required this.report, this.index});

  final Report report;
  final int? index;
}

class ReportViewer extends StatelessWidget {
  ReportViewer({Key? key}) : super(key: key);

  static const String routeName = '/report_viewer';
  final logger = Logger(
    printer: PrettyPrinter(printEmojis: true, printTime: true, colors: true),
  );
  final _controllers = <TextEditingController>[];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReportViewerArgs;

    final report = args.report;

    _controllers.addAll(List.generate(
        report.layout.fields.length, (index) => TextEditingController()));

    for (var i = 0; i < report.data.length; i++) {
      _controllers[i].text = report.data[i].text;
    }

    final List<Widget> shareAction = [];
    if (args.index != null)
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
        title: Text(report.title),
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
                  controllers: _controllers,
                  report: report,
                  index: args.index,
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
      required this.report,
      required this.controllers,
      required this.index})
      : super(key: key);
  final Report report;
  final List<TextEditingController> controllers;
  final int? index;
  final logger = Logger(
    printer: PrettyPrinter(printEmojis: true, printTime: true, colors: true),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('save'),
      onPressed: () {
        for (var i = 0; i < report.layout.fields.length; i++) {
          if (report.data.length <= i) {
            report.data.add(FieldData(text: controllers[i].text));
          } else {
            report.data[i].text = controllers[i].text;
          }
          logger.d('${report.layout.fields[i].title}: ${controllers[i].text}');
        }
        var reports = context.read<ReportsModel>();
        if (index != null)
          reports.update(index!, report);
        else
          reports.add(report);

        Navigator.pop(context);
        logger.i("Saved report");
      },
    );
  }
}
