// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/common/io.dart';
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
        title: Text(AppLocalizations.of(context)!.reportsTitle),
      ),
      floatingActionButton:
          Consumer<LayoutsModel>(builder: (context, layoutsProvider, child) {
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            if (layoutsProvider.layouts.isNotEmpty)
              showCupertinoModalBottomSheet(
                context: context,
                bounce: true,
                closeProgressThreshold: 0.4,
                builder: (context) {
                  final args = ReportViewerArgs(
                      name: 'Report ${DateTime.now().toString()}');
                  return ReportViewer(args: args);
                },
              );
            else
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.reportRequiresLayout),
                ),
              );
          },
        );
      }),
      drawer: MenuDrawer(),
      body: _ReportList(),
    );
  }
}

// -----------------------------------------------------------------------------
// - _ReportList Widget Implementation
// -----------------------------------------------------------------------------

class _ReportList extends StatefulWidget {
  _ReportList({Key? key}) : super(key: key);

  @override
  __ReportListState createState() => __ReportListState();
}

class __ReportListState extends State<_ReportList> {
  @override
  Widget build(BuildContext context) {
    var reportsProvider = context.watch<ReportsModel>();

    return ListView.separated(
      itemCount: reportsProvider.reports.length,
      itemBuilder: (context, i) {
        final item = reportsProvider.reports[i];
        return Slidable(
          key: Key(item),
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: [
            IconSlideAction(
              icon: Icons.delete,
              color: Colors.red,
              onTap: () {
                deleteFile('$reportsDirectory/$item');
                reportsProvider.removeAt(i);
              },
            )
          ],
          child: ListTile(
            title: Text(item),
            leading: Icon(ReportsIcons.report),
            onTap: () => showCupertinoModalBottomSheet(
              context: context,
              bounce: true,
              closeProgressThreshold: 0.4,
              builder: (context) {
                final args = ReportViewerArgs(name: item, index: i);
                return ReportViewer(args: args);
              },
            ),
          ),
        );
      },
      separatorBuilder: (context, i) => Divider(height: 0.0),
    );
  }
}
