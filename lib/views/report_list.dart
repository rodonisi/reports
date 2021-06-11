// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/structures/report_structures.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/models/reports.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/views/menu_drawer.dart';

// -----------------------------------------------------------------------------
// - ReportList Widget Implementation
// -----------------------------------------------------------------------------
class Reports extends StatelessWidget {
  const Reports({Key? key}) : super(key: key);
  static const routeName = "/reports";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('report list'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          var layouts = context.read<LayoutsModel>();
          Navigator.pushNamed(
            context,
            ReportViewer.routeName,
            arguments: ReportViewerArgs(
              report: Report(
                title: 'Report ${DateTime.now().toString()}',
                layout: layouts.layouts[0],
                data: [],
              ),
            ),
          );
        },
      ),
      drawer: MenuDrawer(),
      body: _ReportList(),
    );
  }
}

// -----------------------------------------------------------------------------
// - _ReportList Widget Implementation
// -----------------------------------------------------------------------------
class _ReportList extends StatelessWidget {
  const _ReportList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var reportsProvider = context.watch<ReportsModel>();

    return ListView.separated(
      itemCount: reportsProvider.reports.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(reportsProvider.reports[i].title),
          onTap: () => Navigator.pushNamed(context, ReportViewer.routeName,
              arguments: ReportViewerArgs(
                report: reportsProvider.reports[i],
                index: i,
              )),
        );
      },
      separatorBuilder: (context, i) => Divider(),
    );
  }
}
