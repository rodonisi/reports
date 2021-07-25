// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/dropbox_utils.dart';
import 'package:reports/common/preferences.dart';
import 'package:reports/views/dropbox_chooser.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/controlled_text_field.dart';

// -----------------------------------------------------------------------------
// - Settings View Implementation
// -----------------------------------------------------------------------------

/// Displays the main settings view for the application.
class Settings extends StatefulWidget {
  static const String routeName = '/settings';
  Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? dropboxAccessToken;

  Future getDir() async {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      drawer: MenuDrawer(),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
                _GeneralSettings(prefs: snapshot.data!),
                if (!Platform.isMacOS)
                  _DBSettings(prefs: snapshot.data!, setState: setState),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _GeneralSettings extends StatefulWidget {
  _GeneralSettings({Key? key, required this.prefs}) : super(key: key);

  final SharedPreferences prefs;

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
                  namePref: Preferences.reportBaseName,
                  datePref: Preferences.reportNameDate,
                  timePref: Preferences.reportNameTime,
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
                  namePref: Preferences.layoutBaseName,
                  datePref: Preferences.layoutNameDate,
                  timePref: Preferences.layoutNameTime,
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
  const _DBSettings({Key? key, required this.prefs, required this.setState})
      : super(key: key);

  final SharedPreferences prefs;
  final setState;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    var dbEnabled = prefs.getBool(Preferences.dropboxEnabled);

    if (dbEnabled == null) {
      dbEnabled = false;
      prefs.setBool(Preferences.dropboxEnabled, false);
    }
    // The list of Dropbox-related settings.
    final dbSettingsList = <Widget>[
      SwitchListTile.adaptive(
        title: Text(localizations.dropboxBackup),
        secondary: Icon(FontAwesomeIcons.dropbox),
        value: dbEnabled,
        onChanged: (value) async {
          if (!value) await dbUnlink();
          prefs.setBool(Preferences.dropboxEnabled, value);
          dbEnabled = value;

          setState(() {});
        },
      ),
    ];

    // Only show further settings if Dropbox is enabled.
    if (dbEnabled!) {
      dbSettingsList.add(
        _DBLoginButton(
          setState: setState,
          prefs: prefs,
        ),
      );
      // Add default backup path chooser.
      dbSettingsList.add(
        _DBPathTile(
          dbPath: prefs.getString(Preferences.dropboxPath),
          setState: setState,
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
  const _DBLoginButton({Key? key, required this.setState, required this.prefs})
      : super(key: key);
  final setState;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // TODO: Find a better way to determine this.
    final isAuthorized = prefs.getBool(Preferences.dropboxAuthorized);

    // Show the sign in button if Dropbox is not authorized
    if (isAuthorized == null || !isAuthorized)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Dropbox.authorize();
                  prefs.setBool(Preferences.dropboxAuthorized, true);
                  setState(() {});
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
                await dbUnlink();
                setState(() {});
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
  const _DBPathTile({Key? key, this.dbPath, required this.setState})
      : super(key: key);

  final String? dbPath;
  final setState;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.backupLocation),
      leading: Icon(Icons.folder),
      trailing: Text((dbPath == null || dbPath!.isEmpty) ? '/' : dbPath!),
      onTap: () => Navigator.pushNamed(context, DropboxChooser.routeName,
          arguments: DropboxChooserArgs(setState: setState)),
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
  String? _baseName;
  bool? _includeDate;
  bool? _includeTime;

  Widget _getDivider() {
    return Divider(height: 0.0);
  }

  List<Widget> _getSettings() {
    final localizations = AppLocalizations.of(context)!;
    return [
      ListTile(
        title: Text(localizations.baseName),
        subtitle: ControlledTextField(
          initialValue: _baseName,
          hasClearButton: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
          ),
          onChanged: (value) => setState(() => _baseName = value),
          maxLines: 1,
        ),
      ),
      _getDivider(),
      SwitchListTile.adaptive(
        title: Text(localizations.includeDate),
        value: _includeDate!,
        onChanged: (value) => setState(() {
          _includeDate = value;
        }),
      ),
      _getDivider(),
      SwitchListTile.adaptive(
        title: Text(localizations.inlcudeTime),
        value: _includeTime!,
        onChanged: (value) => setState(() {
          _includeTime = value;
        }),
      ),
      _getDivider(),
      ListTile(
        title: Text(localizations.preview),
        subtitle: Text(
          Preferences.getDefaultNameSync(
              _baseName!, _includeDate!, _includeTime!),
        ),
      ),
    ];
  }

  Widget _getBody(SharedPreferences prefs) {
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
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator.adaptive();
        if (snapshot.hasError) throw snapshot.error!;

        final prefs = snapshot.data!;

        // Set localized default base name.
        if (_baseName == null) {
          final baseNamePref = prefs.getString(widget.namePref);
          if (baseNamePref == null) {
            if (widget.namePref == Preferences.reportBaseName)
              _baseName = localizations.report;
            else
              _baseName = localizations.layout;
          } else {
            _baseName = baseNamePref;
          }
        }

        // Set default include date setting.
        if (_includeDate == null)
          _includeDate = prefs.getBool(widget.datePref) ??
              Preferences.getDefault(widget.datePref) as bool;

        // Set default include time setting.
        if (_includeTime == null)
          _includeTime = prefs.getBool(widget.timePref) ??
              Preferences.getDefault(widget.timePref) as bool;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            leading: BackButton(
              onPressed: () async {
                await prefs.setString(widget.namePref, _baseName!);
                await prefs.setBool(widget.datePref, _includeDate!);
                await prefs.setBool(widget.timePref, _includeTime!);

                Navigator.pop(context);
              },
            ),
          ),
          body: _getBody(prefs),
        );
      },
    );
  }
}
