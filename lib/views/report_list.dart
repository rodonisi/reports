// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:reports/utilities/logger.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/directory_viewer.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/sidebar_layout.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - Reports Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a nested navigator managing the reports navigation.
class Reports extends StatelessWidget {
  static const routeName = "/reports";
  static const ValueKey valueKey = ValueKey('Reports');

  const Reports({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final prefs = context.watch<PreferencesModel>();

    // Generate additional pages based on the current app state.
    final pagesList = <MaterialPage>[];
    if (appState.reportsListPath.isNotEmpty) {
      final paths = getSubPaths(
          p.relative(appState.reportsListPath, from: prefs.reportsPath));
      paths.forEach((element) {
        pagesList.add(
          MaterialPage(
            key: ValueKey(p.join(ReportsList.valueKey.value, element)),
            name: p.join(prefs.reportsPath, element),
            child: ReportsList(
              path: p.join(prefs.reportsPath, element),
            ),
          ),
        );
      });
    }
    return WrapNavigator(
      child: MaterialPage(
        key: ReportsList.valueKey,
        child: ReportsList(
          path: '',
        ),
      ),
      additionalPages: pagesList,
      onPopPage: (route, result) {
        // Get the parent directory path.
        final dir = p.dirname(route.settings.name ?? '');
        // Set the app state to the parent directory or empty if on the root
        // reports directory.
        appState.reportsListPath = dir == prefs.reportsPath ? '' : dir;
        return route.didPop(result);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// - ReportsList Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a directory navigator for the reports folder.
class ReportsList extends StatefulWidget {
  static const ValueKey valueKey = ValueKey('ReportsList');

  const ReportsList({Key? key, required this.path}) : super(key: key);

  /// The full path to the reports directory to display. If an empty path ('') is
  /// provided, the base reports directory $reportsDirectory is picked.
  final String path;

  @override
  _ReportsListState createState() => _ReportsListState();
}

class _ReportsListState extends State<ReportsList> {
  late Directory _dir;
  late bool _showDrawer;

  Widget _getList() {
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
      directoryAction: (Directory item) =>
          context.read<AppStateModel>().reportsListPath = item.path,
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
    if (widget.path.isEmpty) {
      // Set the path to the base reportsDirectory if no path is provided.
      _dir = context.read<PreferencesModel>().reportsDirectory;
      // Only show the drawer if we're on the reports root folder and in narrow
      // layout.
      _showDrawer =
          context.findAncestorWidgetOfExactType<SideBarLayout>() == null;
    } else {
      // Just set the directory otherwise.
      _dir = Directory(widget.path);
      _showDrawer = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();
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
      drawer: _showDrawer ? Drawer(child: MenuDrawer()) : null,
      floatingActionButton: prefs.readerMode
          ? null
          : FloatingActionButton(
              backgroundColor: prefs.accentColor,
              child: Icon(Icons.add),
              onPressed: () async {
                final layouts = getLayoutsList(context);
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
                      content: Text(
                          AppLocalizations.of(context)!.reportRequiresLayout),
                    ),
                  );
              },
            ),
      body: _getList(),
    );
  }
}
