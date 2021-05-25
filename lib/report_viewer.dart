import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:logger/logger.dart';

import 'report_structures.dart';

class ReportViewer extends StatelessWidget {
  ReportViewer({
    Key key,
    // this.layout,
    this.report,
  }) : super(key: key);

  // final ReportLayout layout;
  final Report report;

  // final Report report;
  final logger = Logger(
    printer: PrettyPrinter(
      printEmojis: true,
      printTime: true,
      colors: true,
    ),
  );
  final controllers = <TextEditingController>[];

  Widget _getField(FieldOptions options, int i) {
    switch (options.fieldType) {
      case 0:
        return TextField(
          controller: controllers[i],
        );
      case 1:
        return DateTimeFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.event_note),
          ),
          mode: DateTimeFieldPickerMode.time,
          enabled: false,
        );
      case 2:
        return DateTimeFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.event_note),
          ),
          mode: DateTimeFieldPickerMode.date,
          enabled: false,
        );
      case 3:
        return DateTimeFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.event_note),
          ),
          mode: DateTimeFieldPickerMode.dateAndTime,
          enabled: false,
        );
      case 4:
        return Row(
          children: [
            Expanded(
                child: DateTimeFormField(
              mode: DateTimeFieldPickerMode.time,
              enabled: false,
            )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('-'),
            ),
            Expanded(
                child: DateTimeFormField(
              mode: DateTimeFieldPickerMode.time,
              enabled: false,
            )),
          ],
        );
      default:
        return null;
    }
  }

  Widget _buildPopupDialog(BuildContext context, text) {
    return new AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    controllers.addAll(List.generate(
        report.layout.fields.length, (index) => TextEditingController()));

    for (var i = 0; i < report.data.length; i++) {
      controllers[i].text = report.data[i].text;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            itemBuilder: (context, i) {
              if (i < report.layout.fields.length) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(report.layout.fields[i].title),
                              _getField(report.layout.fields[i], i)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return null;
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildPopupDialog(context, report.toJSON()));
                    },
                    child: Text('export'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    child: Text('save'),
                    onPressed: () {
                      for (var i = 0; i < report.layout.fields.length; i++) {
                        if (report.data.length <= i) {
                          report.data.add(FieldData(text: controllers[i].text));
                        } else {
                          report.data[i].text = controllers[i].text;
                        }
                        logger.d(
                            '${report.layout.fields[i].title}: ${controllers[i].text}');
                      }
                      Navigator.pop(context, report);
                      logger.i("Saved report");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
