// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/io.dart';
import 'package:reports/common/logger.dart';

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
Future<void> dbBackupFile(
    BuildContext context, String file, String directory) async {
  // Throw exception if not authorized.
  if (!(await dbCheckAuthorized(context)))
    throw Exception('Dropbox is not authorized');

  // Get the full path to the file's directory.
  final localPath = p.join((await getLocalDocsPath), p.basename(directory));

  // Get Dropbox base path.
  final prefs = context.read<PreferencesModel>();
  String dbPath = prefs.dropboxPath;
  dbPath = p.join(dbPath, p.basename(directory));

  // Upload the file.
  Dropbox.upload(p.join(localPath, file), p.join(dbPath, file));
}

Future<void> _dbBackupList(
    List<FileSystemEntity> list, String dropboxPath) async {
  for (final element in list) {
    if (element is File) {
      final relativePath =
          p.relative(element.path, from: await getLocalDocsPath);
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

  // Get base Dropbox path.
  final prefs = context.read<PreferencesModel>();
  final dbPath = prefs.dropboxPath;
  // Get report files.
  final lsReports = await getDirectoryList(reportsDirectory);
  // Backup repots.
  _dbBackupList(lsReports, dbPath);

  // Get layout files.
  final lsLayouts = await getDirectoryList(layoutsDirectory);
  // Backup layouts.
  _dbBackupList(lsLayouts, dbPath);
}
