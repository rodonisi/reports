// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/models/preferences_model.dart';

/// Authorize Dropbox access with token, if present, or ask for authorization.
/// The token is then returned as result.
Future<bool> dbCheckAuthorized(BuildContext context) async {
  final prefs = context.read<PreferencesModel>();
  var token = prefs.dropboxAccessToken;
  logger.d("Stored Dropbox acces token: $token");

  // Try getting a fresh token if we don't have any stored.
  if (token.isEmpty) {
    token = await Dropbox.getAccessToken() ?? '';
  }

  if (token.isNotEmpty) {
    // Store the token.
    prefs.dropboxAccessToken = token;

    // Authorize Dropbox.
    await Dropbox.authorizeWithAccessToken(token);

    return true;
  }

  return false;
}

/// Unlink the user account from dropbox and reset the preferences.
void dbUnlink(BuildContext context) {
  // Unlink Dropbox.
  Dropbox.unlink();

  // Set back stored settings.
  final prefs = context.read<PreferencesModel>();
  prefs.dropboxAccessToken = '';
  prefs.dropboxPath = '';
  prefs.dropboxAuthorized = false;
}

Future<dynamic> dbListFolder(BuildContext context, String path) async {
  if (!(await dbCheckAuthorized(context)))
    throw Exception('Dropbox is not authorized');

  return Dropbox.listFolder(path);
}

/// Backup a single file to dropbox.
Future<void> dbBackupFile(BuildContext context, String filePath) async {
  // Throw exception if not authorized.
  if (!(await dbCheckAuthorized(context)))
    throw Exception('Dropbox is not authorized');
  final prefs = context.read<PreferencesModel>();

  // Get the full path to the file's directory.
  final relative = p.relative(filePath, from: prefs.localDocsPath);

// Get destination path
  final destination = p.join(prefs.dropboxPath, relative);

  // Upload the file.
  Dropbox.upload(filePath, destination);
}

Future<void> _dbBackupList(
    List<FileSystemEntity> list, String docsPath, String dropboxPath) async {
  for (final element in list) {
    if (element is File) {
      final relativePath = p.relative(element.path, from: docsPath);
      await Dropbox.upload(
        element.path,
        p.join(dropboxPath, relativePath),
        (uploaded, total) =>
            logger.v('Uploading $relativePath: $uploaded/$total'),
      );
    }
  }
}

/// Backup all local layouts and reports to dropbox.
Future<void> dbBackupEverything(BuildContext context) async {
  // Throw exception if Dropbox is not authorized.
  if (!(await dbCheckAuthorized(context)))
    throw Exception('Dropbox is not authorized');

  // Get base paths.
  final prefs = context.read<PreferencesModel>();
  final dbPath = prefs.dropboxPath;
  final docsPath = prefs.defaultPath;

  // Get report files.
  final lsReports = prefs.reportsDirectory.listSync(recursive: true);
  // Backup repots.
  _dbBackupList(lsReports, docsPath, dbPath);

  // Get layout files.
  final lsLayouts = prefs.layoutsDirectory.listSync();
  // Backup layouts.
  _dbBackupList(lsLayouts, docsPath, dbPath);
}
