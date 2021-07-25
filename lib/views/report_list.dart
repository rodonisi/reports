// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/common/logger.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/common/io.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/controlled_text_field.dart';

// -----------------------------------------------------------------------------
// - ReportList Widget Implementation
// -----------------------------------------------------------------------------

/// Displays all the reports stored in the app in a list.
class Reports extends StatefulWidget {
  static const routeName = "/reports";
  const Reports({Key? key, required this.path}) : super(key: key);

  /// The full path to the reports directory to display. If an empty path ('') is
  /// provided, the base reports directory $reportsDirectory is picked.
  final String path;

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late Directory _dir;
  bool _loaded = false;

  Widget _getTile(FileSystemEntity item) {
    final isFile = item is File;

    // Tapping a report opens it in a modal sheet.
    final fileOnTap = () => showCupertinoModalBottomSheet(
          context: context,
          bounce: true,
          closeProgressThreshold: 0.4,
          builder: (context) {
            final args = ReportViewerArgs(path: item.path);
            return ReportViewer(args: args);
          },
        ).then(
          (value) => setState(() {}),
        );

    // Tapping a directory pushes a new report list for the new directory.
    final dirOnTap = () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Reports(
              path: item.path,
            ),
          ),
        );

    return Slidable(
      key: ObjectKey(item),
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          icon: Icons.adaptive.share,
          color: Colors.blue,
          onTap: () => Share.shareFiles([item.path]),
        ),
        IconSlideAction(
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            setState(() => item.deleteSync(recursive: true));
          },
        )
      ],
      child: ListTile(
          title: Text(p.basenameWithoutExtension(item.path)),
          leading: Icon(isFile ? ReportsIcons.report : Icons.folder),
          trailing: isFile ? null : Icon(Icons.keyboard_arrow_right_rounded),
          onTap: isFile ? fileOnTap : dirOnTap),
    );
  }

  Widget _getList() {
    if (!_loaded)
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );

    // Get the updated directory list.
    final list = _dir.listSync();
    // Sort the list by paths.
    list.sort((a, b) => a.path.compareTo(b.path));

    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final item = list[i];
        return _getTile(item);
      },
      separatorBuilder: (context, i) => Divider(height: 0.0),
    );
  }

  Widget _getNewFolderDialog(BuildContext context) {
    String folderName = '';
    return AlertDialog(
      title: Text('New Folder'),
      content: ControlledTextField(
        hasClearButton: true,
        onChanged: (value) => folderName = value,
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (folderName.isNotEmpty) {
              final path = p.join(_dir.path, folderName);
              logger.d('Created folder: $path');
              setState(() => Directory(path).createSync());
            }
            Navigator.pop(context);
          },
          child: Text('Create'),
        ),
      ],
    );
  }

  @override
  void initState() {
    // Set the path to the base reportsDirectory if no path is provided.
    if (widget.path.isEmpty) {
      getReportsDirectory.then((value) {
        setState(() {
          _loaded = true;
          _dir = Directory(value);
        });
      });
    } else {
      // Just set the directory otherwise.
      _loaded = true;
      _dir = Directory(widget.path);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.isEmpty
            ? AppLocalizations.of(context)!.reportsTitle
            : p.basename(widget.path)),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: _getNewFolderDialog,
              );
            },
            icon: Icon(Icons.create_new_folder_outlined),
          ),
        ],
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
                  final args = ReportViewerArgs(path: _dir.path);
                  return ReportViewer(args: args);
                },
              ).then((value) => setState(() {}));
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
      drawer: widget.path.isEmpty ? MenuDrawer() : null,
      body: _getList(),
    );
  }
}
