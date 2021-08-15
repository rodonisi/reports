// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:reports/utilities/logger.dart';
import 'package:reports/models/preferences_model.dart';

// -----------------------------------------------------------------------------
// - Constants
// -----------------------------------------------------------------------------
const String layoutsDirectoryPath = 'layouts';
const String reportsDirectoryPath = 'reports';

// -----------------------------------------------------------------------------
// - IO Utilities
// -----------------------------------------------------------------------------

/// Compare FileSystemEntities by their paths
int fileSystemEntityComparator(FileSystemEntity a, FileSystemEntity b) {
  return a.path.compareTo(b.path);
}

/// Get the list of layouts stored in the local layouts directory.
List<File> getLayoutsList(BuildContext context) {
  final dir = context.read<PreferencesModel>().layoutsDirectory;
  final list = dir.listSync();

  final List<File> selected = list.whereType<File>().toList();

  selected.sort(fileSystemEntityComparator);

  return selected;
}

/// Write the given string to the destination path. Optionally check if a file
/// already exists for that destionation, or rename from another path.
Future<bool> writeToFile(String string, String destination,
    {bool checkExisting = false, String renameFrom = ''}) async {
  File destFile = File(destination);
  if (checkExisting && await destFile.exists()) {
    logger.d('File $destination already exists.');
    return false;
  }

  if (renameFrom.isNotEmpty && renameFrom != destination) {
    logger.d('Renaming file: $renameFrom => $destination');
    destFile = await File(renameFrom).rename(destination);
  }

  logger.d('Writing file: $destination');
  await destFile.writeAsString(string);

  return true;
}

/// Synchronously create a directory for the given path.
void createDir(String path) {
  final dir = Directory(path);
  dir.createSync(recursive: true);
}

/// Join two paths and set the extension. The extension defaults to json.
String joinAndSetExtension(String part0, String part1,
    {String extension = '.json'}) {
  String path = p.join(part0, part1);
  return p.setExtension(path, extension);
}

/// Get a list of all sub paths for the given path.
List<String> getSubPaths(String path) {
  final List<String> list = [];

  // Get all path elements.
  final elements = p.split(path);
  for (var i = 0, e = elements.length; i < e; i++) {
    // Join the elements up to the j'th element.
    String subPath = '';
    for (var j = 0; j <= i; j++) {
      subPath = p.join(subPath, elements[j]);
    }
    list.add(subPath);
  }

  return list;
}
