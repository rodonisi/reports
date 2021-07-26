// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/logger.dart';

// -----------------------------------------------------------------------------
// - Global Strings
// -----------------------------------------------------------------------------
const String layoutsDirectory = '/layouts';
const String reportsDirectory = '/reports';

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
  final path = basePath + layoutsDirectory;
  await Directory(path).create(recursive: true);

  return path;
}

/// Get the local directory where the reports live.
Future<String> get getReportsDirectory async {
  final basePath = await getLocalDocsPath;

  // Ensure the directory exists
  final path = basePath + reportsDirectory;
  await Directory(path).create(recursive: true);

  return path;
}

/// Get all the files contained in the given directory path as a list.
Future<List<File>> getLocalDirFiles(String dirPath) async {
  List<File> files = [];
  final basePath = await getLocalDocsPath;

  // Get a directory path for the given directory.
  final dir = await Directory(basePath + dirPath).create(recursive: true);

  // Gather all the files in the directory.
  for (var entry in dir.listSync()) {
    if (entry is File) {
      files.add(entry);
      logger.d('Found file ${entry.path}');
    }
  }

  return files;
}

/// Read a file given its path in the app's document directory.
Future<String> readFromPath(String path) async {
  final basePath = await getLocalDocsPath;

  final file = File(basePath + path);
  return file.readAsString();
}

/// Read a layout file given its name.
Future<String> readNamedLayout(String name) async {
  logger.d('Reading layout: $name');

  return readFromPath('$layoutsDirectory/$name.json');
}

/// Read a report file given its name.
Future<String> readNamedReport(String name) async {
  logger.d('Reading report: $name');

  return readFromPath('$reportsDirectory/$name.json');
}

/// Synchronously read a file.
String readFile(File file) {
  return file.readAsStringSync();
}

/// Write a file. If the file does not exist a new one is created.
Future<File> writeFile(String path, String content) async {
  final basePath = await getLocalDocsPath;

  // Get the file object for the given path. Create a new one if none exists
  // (including the directory if we are writing to it for the first time).
  final file = await File(basePath + path + '.json').create(recursive: true);

  logger.d('Created file ${file.path}');

  final result = await file.writeAsString(content);
  logger.d('Written file ${result.path}');

  return result;
}

/// Try to rename an existing file or create a new file if no file exists for
/// the old path.
Future<File> renameOrCreate(String oldPath, String newPath) async {
  final basePath = await getLocalDocsPath;
  final file = File(basePath + oldPath + '.json');

  // Check if the file exists already.
  if (await file.exists()) {
    final renamed = await file.rename(basePath + newPath + '.json');
    logger.d('Moved file ${file.path} -> ${renamed.path}');

    return renamed;
  }

  // Create a new file if no file exists for the old path (inlcuding the
  // directory if we are writing to it for the first time).
  final newFile =
      await File(basePath + newPath + '.json').create(recursive: true);
  logger.d('Created file ${newFile.path}');

  return newFile;
}

/// Rename and write a file. If no file with the old path exists, a new one is
/// created and written instead.
Future<void> renameAndWriteFile(
    String oldPath, String newPath, String content) async {
  final file = await renameOrCreate(oldPath, newPath);
  await file.writeAsString(content);
  logger.d('Written file ${file.path}');
}

/// Delete a file.
void deleteFile(String path) async {
  final basePath = await getLocalDocsPath;
  final file = File(basePath + path + '.json');

  // Delete the file if it exists.
  if (await file.exists()) {
    file.delete();
    logger.d('Deleted file ${file.path}');
  }
}

/// Get the (sorted) list of layouts as files. Any directory in the layout
/// folder is signored.
Future<List<File>> getLayoutsList() async {
  final layoutsDirectory = Directory(await getLayoutsDirectory);
  final dirList = layoutsDirectory.listSync();
  final List<File> layoutsList = [];

  for (var entity in dirList) {
    if (entity is File) layoutsList.add(entity);
  }

  layoutsList.sort((a, b) => a.path.compareTo(b.path));

  return layoutsList;
}
