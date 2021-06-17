// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/models/reports.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/views/menu_drawer.dart';

// -----------------------------------------------------------------------------
// - ReportList Widget Implementation
// -----------------------------------------------------------------------------

/// Displays all the reports stored in the app in a list.
class Reports extends StatelessWidget {
  static const routeName = "/reports";
  const Reports({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      floatingActionButton: Consumer<LayoutsModel>(
        builder: (context, layoutsProvider, child) => FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(
              context,
              ReportViewer.routeName,
              arguments:
                  ReportViewerArgs(name: 'Report ${DateTime.now().toString()}'),
            );
          },
        ),
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
          title: Text(reportsProvider.reports[i]),
          leading: Icon(ReportsIcons.report),
          onTap: () => Navigator.pushNamed(
            context,
            ReportViewer.routeName,
            arguments: ReportViewerArgs(
              name: reportsProvider.reports[i],
              index: i,
            ),
          ),
        );
      },
      separatorBuilder: (context, i) => Divider(),
    );
  }
}
