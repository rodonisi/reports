// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reports/common/logger.dart';

// -----------------------------------------------------------------------------
// - Global Strings
// -----------------------------------------------------------------------------
const String layoutsDirectory = 'layouts/';
const String reportsDirectory = 'reports/';

// -----------------------------------------------------------------------------
// - IO Utilities
// -----------------------------------------------------------------------------

/// Get the local documents path as given by the path_provider package.
Future<String> get getLocalDocsPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

/// Get the local directory where the layouts live.
Future<String> get getLayoutsDirectory async {
  final basePath = await getLocalDocsPath;

  // Ensure the directory exists
  final path = p.join(basePath, layoutsDirectory);
  await Directory(path).create(recursive: true);

  return path;
}

/// Get the local directory where the reports live.
Future<String> get getReportsDirectory async {
  final basePath = await getLocalDocsPath;

  // Ensure the directory exists
  final path = p.join(basePath, reportsDirectory);
  await Directory(path).create(recursive: true);

  return path;
}

int compareFileSystemEntities(FileSystemEntity a, FileSystemEntity b) {
  return a.path.compareTo(b.path);
}

Future<List<FileSystemEntity>> getDirectoryList(String dir) async {
  final path = p.join(await getLocalDocsPath, dir);
  final directory = Directory(path);
  return await directory.list(recursive: true).toList();
}

Future<List<File>> getLayoutsList() async {
  final list = await getDirectoryList(layoutsDirectory);
  final List<File> layoutsList = [];
  list.forEach((element) {
    if (element is File) {
      layoutsList.add(element);
    }
  });

  layoutsList.sort(compareFileSystemEntities);

  return layoutsList;
}

Future<bool> writeToFile(String string, String destination,
    {bool checkExisting = false,
    String renameFrom = '',
    bool dropboxBackup = false}) async {
  File destFile = File(destination);
  if (checkExisting && await destFile.exists()) {
    logger.d('File $destination already exists.');
    return false;
  }

  if (renameFrom.isNotEmpty) {
    logger.d('Renamed file: $renameFrom => $destination');
    destFile = await File(renameFrom).rename(destination);
  }

  await destFile.writeAsString(string);

  return true;
}
