import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'report_viewer.dart';
import 'form_builder.dart';
import 'report_structures.dart';

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
  var _layout = ReportLayout(fields: []);
  var c = 0;

  _navigateAndDisplaySelection(BuildContext context) async {
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
              layout: ReportLayout(fields: _layout.fields),
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

  _pushLayout(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormBuilder(layout: _layout.fields),
        ));

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      setState(() {
        _layout = ReportLayout(fields: result);
      });
      _logger.i('Updated layout');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('report list'),
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => _pushLayout(context),
        ),
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
