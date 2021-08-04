// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/widgets/directory_viewer.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/common/io.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/widgets/controlled_text_field.dart';

// -----------------------------------------------------------------------------
// - ReportList Widget Implementation
// -----------------------------------------------------------------------------

/// Displays all the reports stored in the app in a list.
class Reports extends StatefulWidget {
  static const routeName = "/reports";
  static const ValueKey valueKey = ValueKey('Reports');

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

  Widget _getList() {
    if (!_loaded)
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );

    return DirectoryViewer(
      fileIcon: ReportsIcons.report,
      fileAction: (File item) => showCupertinoModalBottomSheet(
        context: context,
        bounce: true,
        closeProgressThreshold: 0.4,
        builder: (context) {
          final args = ReportViewerArgs(path: item.path);
          return ReportViewer(args: args);
        },
      ).then(
        (value) => setState(() {}),
      ),
      directoryAction: (Directory item) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Reports(
            path: item.path,
          ),
        ),
      ),
      directoryPath: _dir.path,
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
            icon: Icon(Icons.create_new_folder),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final layouts = await getLayoutsList();
          if (layouts.isNotEmpty)
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
      ),
      body: _getList(),
    );
  }
}
