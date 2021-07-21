// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
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
