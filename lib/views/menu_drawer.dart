// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';
import 'dart:io';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as p;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/utilities/logger.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/views/import_reports.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/widgets/container_tile.dart';

/// Displays the menu navigator as a navigation rail.
class MenuRail extends StatelessWidget {
  const MenuRail({Key? key, this.extended = false}) : super(key: key);

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final prefs = context.watch<AppStateModel>();
    return NavigationRail(
      extended: extended,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(ReportsIcons.report),
          label: Text(localizations.reportsTitle),
        ),
        NavigationRailDestination(
          icon: const Icon(ReportsIcons.layout),
          label: Text(localizations.layoutsTitle),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings),
          label: Text(localizations.settings),
        ),
      ],
      selectedIndex: prefs.getIndexFromPage(),
      onDestinationSelected: (index) {
        prefs.setPageFromIndex(index);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// - MenuDrawer Widget Implementation
// -----------------------------------------------------------------------------

/// Creates the menu drawer for the app.
class MenuDrawer extends StatelessWidget {
  static const String routeName = '/';
  static const ValueKey valueKey = ValueKey('MenuDrawer');
  const MenuDrawer({Key? key}) : super(key: key);

  Widget _getSeparator() {
    return const SizedBox(
      height: 32.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appState = context.read<AppStateModel>();
    return Scaffold(
      body: SafeArea(
        top: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          children: [
            ContainerTile(
              title: Text(localizations.reportsTitle),
              leading: const Icon(ReportsIcons.report),
              selected: appState.currentPage == Pages.reports,
              onTap: () =>
                  context.read<AppStateModel>().currentPage = Pages.reports,
            ),
            ContainerTile(
              title: Text(localizations.layoutsTitle),
              leading: const Icon(ReportsIcons.layout),
              selected: appState.currentPage == Pages.layouts,
              onTap: () =>
                  context.read<AppStateModel>().currentPage = Pages.layouts,
            ),
            _getSeparator(),
            if (!Platform.isMacOS) ...[
              _ImportTile(),
              _getSeparator(),
            ],
            ContainerTile(
              title: Text(localizations.settings),
              leading: const Icon(Icons.settings),
              selected: appState.currentPage == Pages.settings,
              onTap: () =>
                  context.read<AppStateModel>().currentPage = Pages.settings,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportTile extends StatelessWidget {
  const _ImportTile({Key? key}) : super(key: key);

  void _importReportCallback(BuildContext context) async {
    await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['.json']).then((picked) async {
      if (picked != null) {
        // Select only reports, ignore anything else.
        final list = picked.files.where((element) {
          final file = File(element.path!);
          final decoded = jsonDecode(file.readAsStringSync());
          return decoded[FileHeader.typeID] == FileHeader.reportID;
        }).toList();

        // Show import screen if there are any selected reports.
        if (list.isNotEmpty) {
          await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) {
              return ImportReportsView(files: list);
            },
            settings: const RouteSettings(name: 'ImportLayout'),
          );
        }
      }
      Navigator.pop(context);
    });
  }

  Future<void> _importLayoutsCallback(BuildContext context) async {
    await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['.json']).then(
      (picked) {
        if (picked != null) {
          final localizations = AppLocalizations.of(context)!;

          // Iterate over the picked files.
          picked.files.forEach((element) async {
            final file = File(element.path!);

            // Check if the picked file is a layout.
            final decodedContent = jsonDecode(await file.readAsString());
            final type = decodedContent[FileHeader.typeID] as String?;
            if (type != null && type == FileHeader.layoutID) {
              // Get final path.
              final path = p.join(
                  context.read<PreferencesModel>().layoutsPath, element.name);

              // Check if a file already exists at the destination.
              if (File(path).existsSync()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(localizations.fileExists(localizations.report)),
                  backgroundColor: Colors.red,
                ));
                return;
              }

              logger.d('Imported layout to path $path');

              // Copy file.
              await file.copy(path);
            }
            Navigator.pop(context);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ContainerTile(
      title: Text(localizations.import),
      leading: const Icon(Icons.save_alt),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ContainerTile(
                title: Text(localizations.importReports),
                onTap: () {
                  _importReportCallback(context);
                },
              ),
              ContainerTile(
                title: Text(localizations.importLayouts),
                onTap: () {
                  _importLayoutsCallback(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
