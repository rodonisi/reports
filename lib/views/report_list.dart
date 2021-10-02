// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/constants.dart';
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
// - ReportsList Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a nested navigator managing the reports navigation.
class ReportsList extends StatelessWidget {
  static const ValueKey valueKey = ValueKey('ReportsList');

  const ReportsList({
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
            key: ValueKey(p.join(_Body.valueKey.value, element)),
            name: p.join(prefs.reportsPath, element),
            child: _Body(
              path: p.join(prefs.reportsPath, element),
            ),
          ),
        );
      });
    }
    return WrapNavigator(
      child: MaterialPage(
        key: _Body.valueKey,
        child: _Body(
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
// - _Body Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a directory navigator for the reports folder.
class _Body extends StatefulWidget {
  static const ValueKey valueKey = ValueKey('ReportsListBody');

  const _Body({Key? key, required this.path}) : super(key: key);

  /// The full path to the reports directory to display. If an empty path ('') is
  /// provided, the base reports directory $reportsDirectory is picked.
  final String path;

  @override
  _ReportsListState createState() => _ReportsListState();
}

class _ReportsListState extends State<_Body> {
  late Directory _dir;
  late bool _showDrawer;

  Widget _getList() {
    return DirectoryViewer(
      fileAction: (File item) => showCupertinoModalBottomSheet(
        context: context,
        bounce: true,
        closeProgressThreshold: DrawingConstants.safeSheetCloseTreshold,
        builder: (context) => ReportViewer(path: item.path),
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
      title: const Text('reports_list.new_folder').tr(),
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
          child: const Text('@.capitalize:keywords.create').tr(),
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
                ? '@.capitalize:keywords.reports'
                : p.basename(widget.path))
            .tr(),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: _getNewFolderDialog,
              );
            },
            icon: const Icon(Icons.create_new_folder),
          ),
        ],
      ),
      drawer: _showDrawer ? const Drawer(child: const MenuDrawer()) : null,
      floatingActionButton: prefs.readerMode
          ? null
          : FloatingActionButton(
              backgroundColor: prefs.accentColor,
              foregroundColor: Theme.of(context).primaryIconTheme.color,
              child: const Icon(Icons.add),
              onPressed: () async {
                final layouts = getLayoutsList(context);
                if (layouts.isNotEmpty)
                  showCupertinoModalBottomSheet(
                    context: context,
                    bounce: true,
                    closeProgressThreshold:
                        DrawingConstants.safeSheetCloseTreshold,
                    builder: (context) => ReportViewer(path: _dir.path),
                  ).then((value) => setState(() {}));
                else
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('reports_list.requires_layouts').tr(),
                    ),
                  );
              },
            ),
      body: _getList(),
    );
  }
}
