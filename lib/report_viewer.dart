import 'package:flutter/material.dart';
import 'form_builder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:date_field/date_field.dart';
import 'package:logger/logger.dart';

class FieldData {
  FieldData({this.text});

  String text;
}

class Report {
  Report({this.fields, this.data});

  final List<FieldOptions> fields;
  final List<FieldData> data;
}

class ReportViewer extends StatelessWidget {
  const ReportViewer({Key key, this.report}) : super(key: key);
  final Report report;

  @override
  Widget build(BuildContext context) {
    Widget _getField(FieldOptions options, FieldData data) {
      switch (options.fieldType) {
        case 0:
          return Text(
            data.text,
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

    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          if (i < report.fields.length) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.fields[i].title),
                          _getField(report.fields[i], report.data[i])
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
    );
  }
}
