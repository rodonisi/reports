// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/views/settings/appearance_settings.dart';
import 'package:reports/views/settings/dropbox_settings.dart';
import 'package:reports/views/settings/general_settings.dart';
import 'package:reports/views/settings/info.dart';
import 'package:reports/views/settings/macos_settings.dart';
import 'package:reports/widgets/sidebar_layout.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the _SettingsBody view wrapped in a navigator.
class Settings extends StatelessWidget {
  static const String routeName = '/settings';
  static const ValueKey valueKey = ValueKey('Settings');

  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WrapNavigator(
      child: MaterialPage(
        key: _SettingsBody.valueKey,
        name: routeName,
        child: _SettingsBody(),
      ),
    );
  }
}
// -----------------------------------------------------------------------------
// - _SettingsBody View Implementation
// -----------------------------------------------------------------------------

/// Displays the main settings view for the application.
class _SettingsBody extends StatelessWidget {
  static const ValueKey valueKey = ValueKey('SettingsBody');

  _SettingsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show the drawer if in narrow layout.
    final showDrawer =
        context.findAncestorWidgetOfExactType<SideBarLayout>() == null;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      drawer: showDrawer ? const Drawer(child: const MenuDrawer()) : null,
      body: ListView(
        children: [
          const AppearanceSettings(),
          if (Platform.isMacOS) const MacosSettings(),
          GeneralSettings(),
          if (!Platform.isMacOS) const DropboxSettings(),
          const Info(),
        ],
      ),
    );
  }
}
