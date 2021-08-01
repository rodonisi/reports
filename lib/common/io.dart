// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
