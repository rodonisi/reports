// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_selector/file_selector.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/dropbox_utils.dart';
import 'package:reports/views/dropbox_chooser.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/sidebar_layout.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the SettingsBody view wrapped in a navigator.
class Settings extends StatelessWidget {
  static const String routeName = '/settings';
  static const ValueKey valueKey = ValueKey('Settings');

  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WrapNavigator(
      child: MaterialPage(
        key: SettingsBody.valueKey,
        child: SettingsBody(),
      ),
    );
  }
}
// -----------------------------------------------------------------------------
// - SettingsBody View Implementation
// -----------------------------------------------------------------------------

/// Displays the main settings view for the application.
class SettingsBody extends StatelessWidget {
  static const ValueKey valueKey = ValueKey('SettingsBody');

  SettingsBody({Key? key}) : super(key: key);

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
      drawer: showDrawer ? Drawer(child: MenuDrawer()) : null,
      body: ListView(
        children: [
          if (Platform.isMacOS) _MacosSettings(),
          _GeneralSettings(),
          if (!Platform.isMacOS) _DBSettings(),
        ],
      ),
    );
  }
}

class _MacosSettings extends StatelessWidget {
  const _MacosSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text('Default Path'),
            subtitle: Text(prefs.defaultPath),
            onTap: () async {
              final dir = await getDirectoryPath();
              logger.d(dir);
              if (dir != null) prefs.defaultPath = dir;
            },
          ),
          SwitchListTile.adaptive(
            title: Text('Reader Mode'),
            value: prefs.readerMode,
            onChanged: (value) => prefs.readerMode = value,
          ),
        ],
      ),
    );
  }
}

class _GeneralSettings extends StatefulWidget {
  _GeneralSettings({Key? key}) : super(key: key);

  @override
  __GeneralSettingsState createState() => __GeneralSettingsState();
}

class __GeneralSettingsState extends State<_GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(localizations.defaultReportNaming),
            trailing: Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _DefaultNamingView(
                  title: localizations.defaultReportNaming,
                  namePref: PreferenceKeys.reportBaseName,
                  datePref: PreferenceKeys.reportNameDate,
                  timePref: PreferenceKeys.reportNameTime,
                ),
              ),
            ),
          ),
          Divider(
            height: 0.0,
          ),
          ListTile(
            title: Text(localizations.defaultLayoutNaming),
            trailing: Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _DefaultNamingView(
                  title: localizations.defaultLayoutNaming,
                  namePref: PreferenceKeys.layoutBaseName,
                  datePref: PreferenceKeys.layoutNameDate,
                  timePref: PreferenceKeys.layoutNameTime,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DBSettings extends StatelessWidget {
  const _DBSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final prefs = context.watch<PreferencesModel>();

    // The list of Dropbox-related settings.
    final dbSettingsList = <Widget>[
      SwitchListTile.adaptive(
        title: Text(localizations.dropboxBackup),
        secondary: Icon(FontAwesomeIcons.dropbox),
        value: prefs.dropboxEnabled,
        onChanged: (value) async {
          if (!value) dbUnlink(context);
          prefs.dropboxEnabled = value;
        },
      ),
    ];

    // Only show further settings if Dropbox is enabled.
    if (prefs.dropboxEnabled) {
      dbSettingsList.add(
        _DBLoginButton(),
      );
      // Add default backup path chooser.
      dbSettingsList.add(
        _DBPathTile(
          dbPath: prefs.dropboxPath,
        ),
      );
    }

    // Generate settings card.
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(children: dbSettingsList),
    );
  }
}

class _DBLoginButton extends StatelessWidget {
  const _DBLoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();
    final localizations = AppLocalizations.of(context)!;
    // TODO: Find a better way to determine this.
    final isAuthorized = prefs.dropboxAuthorized;

    // Show the sign in button if Dropbox is not authorized
    if (!isAuthorized)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Dropbox.authorize();
                  prefs.dropboxAuthorized = true;
                },
                child: Text(localizations.signIn),
              ),
            ),
          ],
        ),
      );

    // Show the sign out button otherwise.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () async {
                dbUnlink(context);
              },
              child: Text(localizations.signOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _DBPathTile extends StatelessWidget {
  const _DBPathTile({
    Key? key,
    this.dbPath,
  }) : super(key: key);

  final String? dbPath;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.backupLocation),
      leading: Icon(Icons.folder),
      trailing: Text((dbPath == null || dbPath!.isEmpty) ? '/' : dbPath!),
      onTap: () => Navigator.pushNamed(context, DropboxChooser.routeName,
          arguments: DropboxChooserArgs()),
    );
  }
}

class _DefaultNamingView extends StatefulWidget {
  _DefaultNamingView({
    Key? key,
    required this.title,
    required this.namePref,
    required this.datePref,
    required this.timePref,
  }) : super(key: key);

  final String title;
  final String namePref;
  final String datePref;
  final String timePref;

  @override
  __DefaultNamingViewState createState() => __DefaultNamingViewState();
}

class __DefaultNamingViewState extends State<_DefaultNamingView> {
  Widget _getDivider() {
    return Divider(height: 0.0);
  }

  List<Widget> _getSettings() {
    final localizations = AppLocalizations.of(context)!;
    final prefs = Provider.of<PreferencesModel>(context);
    return [
      ListTile(
        title: Text(localizations.baseName),
        subtitle: ControlledTextField(
          initialValue: prefs.getString(widget.namePref),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
          ),
          onChanged: (value) => prefs.setString(widget.namePref, value),
          maxLines: 1,
        ),
      ),
      _getDivider(),
      SwitchListTile.adaptive(
        title: Text(localizations.includeDate),
        value: prefs.getBool(widget.datePref),
        onChanged: (value) => prefs.setBool(widget.datePref, value),
      ),
      _getDivider(),
      SwitchListTile.adaptive(
        title: Text(localizations.inlcudeTime),
        value: prefs.getBool(widget.timePref),
        onChanged: (value) => prefs.setBool(widget.timePref, value),
      ),
      _getDivider(),
      ListTile(
        title: Text(localizations.preview),
        subtitle: Text(
          PreferencesModel.constructName(
            prefs.getString(widget.namePref),
            prefs.getBool(widget.datePref),
            prefs.getBool(widget.timePref),
          ),
        ),
      ),
    ];
  }

  Widget _getBody() {
    return ListView(
      children: [
        Card(
          margin: EdgeInsets.all(16.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(children: _getSettings()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getBody(),
    );
  }
}
