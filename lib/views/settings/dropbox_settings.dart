// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/utilities/dropbox_utils.dart';
import 'package:reports/views/dropbox_chooser.dart';
import 'package:reports/widgets/list_card.dart';

// -----------------------------------------------------------------------------
// - DropboxSettings Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the dropbox-specific settings for the app.
class DropboxSettings extends StatelessWidget {
  const DropboxSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final prefs = context.watch<PreferencesModel>();

    // The list of Dropbox-related settings.
    final dbSettingsList = <Widget>[
      SwitchListTile.adaptive(
        title: Text(localizations.dropboxBackup),
        secondary: const Icon(FontAwesomeIcons.dropbox),
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
        const _DBLoginButton(),
      );
      // Add default backup path chooser.
      if (prefs.dropboxAuthorized)
        dbSettingsList.add(
          _DBPathTile(
            dbPath: prefs.dropboxPath,
          ),
        );
    }

    // Generate settings card.
    return ListCard(insertDividers: false, children: dbSettingsList);
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await Dropbox.authorize();
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      subtitle: Text((dbPath == null || dbPath!.isEmpty) ? '/' : dbPath!),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return DropboxChooser(args: DropboxChooserArgs());
          },
        ),
      ),
    );
  }
}
