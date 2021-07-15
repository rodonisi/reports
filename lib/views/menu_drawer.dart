// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/settings.dart';

// -----------------------------------------------------------------------------
// - MenuDrawer Widget Implementation
// -----------------------------------------------------------------------------

/// Creates the menu drawer for the app.
class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Text(localizations.reportsTitle),
              leading: Icon(ReportsIcons.report),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Reports.routeName),
            ),
            ListTile(
              title: Text(localizations.layoutsTitle),
              leading: Icon(ReportsIcons.layout),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Layouts.routeName),
            ),
            ListTile(
              title: Text(localizations.settingsTitle),
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
