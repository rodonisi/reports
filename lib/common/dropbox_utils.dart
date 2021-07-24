// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/io.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/common/preferences.dart';

/// Authorize Dropbox access with token, if present, or ask for authorization.
/// The token is then returned as result.
Future<bool> dbCheckAuthorized() async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString(Preferences.dropboxAccessToken);
  logger.d("Stored Dropbox acces token: $token");

  // Try getting a fresh token if we don't have any stored.
  if (token == null || token.isEmpty) {
    token = await Dropbox.getAccessToken();
  }

  if (token != null && token.isNotEmpty) {
    // Store the token.
    await prefs.setString(Preferences.dropboxAccessToken, token);

    // Authorize Dropbox.
    await Dropbox.authorizeWithAccessToken(token);

    return true;
  }

  return false;
}

/// Unlink the user account from dropbox and reset the preferences.
Future<void> dbUnlink() async {
  // Unlink Dropbox.
  Dropbox.unlink();

  // Set back stored settings.
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(Preferences.dropboxAccessToken, '');
  prefs.setString(Preferences.dropboxPath, '');
  prefs.setBool(Preferences.dropboxAuthorized, false);
}

Future<dynamic> dbListFolder(String path) async {
  if (!(await dbCheckAuthorized()))
    throw Exception('Dropbox is not authorized');

  return Dropbox.listFolder(path);
}

/// Backup a single file to dropbox.
Future<void> dbBackupFile(String file, String directory) async {
  // Throw exception if not authorized.
  if (!(await dbCheckAuthorized()))
    throw Exception('Dropbox is not authorized');

  // Get the full path to the file's directory.
  final localPath = p.join((await getLocalDocsPath), directory);

  // Get Dropbox base path.
  final prefs = await SharedPreferences.getInstance();
  var mayDbPath = prefs.getString(Preferences.dropboxPath);
  String dbPath = '';
  if (mayDbPath != null) dbPath = mayDbPath;
  dbPath = p.join(dbPath, directory);

  // Upload the file.
  Dropbox.upload(p.join(localPath, file), p.join(dbPath, file));
}

Future<void> _dbBackupFileList(List<File> files, String path) async {
  for (final file in files) {
    final fileName = p.basename(file.path);
    await Dropbox.upload(
      file.path,
      '$path/$fileName',
      (uploaded, total) =>
          logger.v('Uploading $fileName to $path: $uploaded/$total'),
    );
  }
}

/// Backup all local layouts and reports to dropbox.
Future<void> dbBackupEverything() async {
  // Throw exception if Dropbox is not authorized.
  if (!(await dbCheckAuthorized()))
    throw Exception('Dropbox is not authorized');

  // Get base Dropbox path.
  final prefs = await SharedPreferences.getInstance();
  final dbPath = prefs.getString(Preferences.dropboxPath);

  // Get report files.
  final lsReports = await getLocalDirFiles(reportsDirectory);
  // Get reports destination path.
  final dbReportsPath =
      dbPath == null ? '/$reportsDirectory' : '$dbPath$reportsDirectory';
  // Backup repots.
  _dbBackupFileList(lsReports, dbReportsPath);

  // Get layout files.
  final lsLayouts = await getLocalDirFiles(layoutsDirectory);
  // Get layouts destination path.
  final dbLayoutsPath =
      dbPath == null ? '/$layoutsDirectory' : '$dbPath$layoutsDirectory';
  // Backup layouts.
  _dbBackupFileList(lsLayouts, dbLayoutsPath);
}
