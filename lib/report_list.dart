import 'package:flutter/material.dart';
import 'report_viewer.dart';
import 'form_builder.dart';
import 'package:logger/logger.dart';

class ReportList extends StatefulWidget {
  ReportList({Key key}) : super(key: key);

  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  final _logger = Logger(
    printer: PrettyPrinter(
      printEmojis: true,
      printTime: true,
      colors: true,
    ),
  );
  var _reports = <Report>[];
  var c = 0;

  _navigateAndDisplaySelection(BuildContext context) async {
    final fields = [
      FieldOptions(title: 'field0', fieldType: 0),
      FieldOptions(title: 'field1', fieldType: 0)
    ];
    // final data = [FieldData(text: "")];
    // final report = Report(
    //   fields: fields,
    //   data: data,
    // );
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportViewer(
            report: Report(
              layout: ReportLayout(fields: fields),
              title: 'Report ${DateTime.now().toString()}',
              data: [],
            ),
          ),
        ));

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      setState(() {
        _reports.add(result);
        c++;
      });
      _logger.i('Report addded to list');
    }
  }

  _pushReport(BuildContext context, int i) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportViewer(report: _reports[i]),
        ));

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      setState(() {
        _reports[i] = result;
      });
      _logger.i('Report $i updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('report list'),
      ),
      body: ListView.separated(
        itemCount: _reports.length,
        itemBuilder: (context, i) {
          if (i < _reports.length) {
            return ListTile(
              title: Text(_reports[i].title),
              onTap: () => _pushReport(context, i),
            );
          }

          return null;
        },
        separatorBuilder: (context, i) => Divider(),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _navigateAndDisplaySelection(context)),
    );
  }
}
