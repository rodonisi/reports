import 'package:flutter/material.dart';
import 'form_builder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:date_field/date_field.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class FieldData {
  FieldData({this.text});

  String text;
}

class ReportLayout {
  ReportLayout({this.fields});

  final List<FieldOptions> fields;
}

class Report {
  const Report({this.title, this.layout, this.data});

  final String title;
  final ReportLayout layout;
  final List<FieldData> data;
}

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

  @override
  Widget build(BuildContext context) {
    controllers.addAll(List.generate(
        report.layout.fields.length, (index) => TextEditingController()));

    for (var i = 0; i < report.data.length; i++) {
      controllers[i].text = report.data[i].text;
    }

    // var report = Report(
    //     layout: layout, title: 'Report ${DateTime.now().toString()}', data: []);

    return Scaffold(
      appBar: AppBar(
        title: TextField(report.title),
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
                      Map<String, Object> jsonMap = {};
                      for (var i = 0; i < report.layout.fields.length; i++) {
                        jsonMap[report.layout.fields[i].title] = {
                          'fieldType': report.layout.fields[i].fieldType,
                          'fieldTitle': report.layout.fields[i].title,
                          'data': report.data[i].text
                        };
                      }
                      logger.d(json.encode(jsonMap));
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
