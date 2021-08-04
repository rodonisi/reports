// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';
import 'dart:io';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as p;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/views/import_reports.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/settings.dart';
import 'package:reports/widgets/container_tile.dart';

// -----------------------------------------------------------------------------
// - MenuDrawer Widget Implementation
// -----------------------------------------------------------------------------

/// Creates the menu drawer for the app.
class MenuDrawer extends StatelessWidget {
  static const String routeName = '/';
  const MenuDrawer({Key? key}) : super(key: key);

  Widget _getSeparator() {
    return SizedBox(
      height: 32.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ContainerTile(
              title: Text(localizations.reportsTitle),
              leading: Icon(ReportsIcons.report),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Reports.routeName),
            ),
            ContainerTile(
              title: Text(localizations.layoutsTitle),
              leading: Icon(ReportsIcons.layout),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Layouts.routeName),
            ),
            _getSeparator(),
            _ImportTile(),
            _getSeparator(),
            ContainerTile(
              title: Text(localizations.settings),
              leading: Icon(Icons.settings),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Settings.routeName),
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
            settings: RouteSettings(name: 'ImportLayout'),
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
              final path = p.join(await getLayoutsDirectory, element.name);

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
      color: Theme.of(context).cardColor,
      title: Text(localizations.import),
      leading: Icon(Icons.save_alt),
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
