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
Future<String> get getLocalDocsPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> get getLayoutsDirectory async {
  final basePath = await getLocalDocsPath;
  return basePath + layoutsDirectory;
}

Future<String> get getReportsDirectory async {
  final basePath = await getLocalDocsPath;
  return basePath + reportsDirectory;
}

Future<List<File>> getLocalDirFiles(String dirPath) async {
  List<File> files = [];
  final basePath = await getLocalDocsPath;
  final dir = await Directory(basePath + dirPath).create(recursive: true);

  for (var entry in dir.listSync()) {
    if (entry is File) {
      files.add(entry);
      logger.d('Found file ${entry.path}');
    }
  }

  files.sort((a, b) => a.path.compareTo(b.path));

  return files;
}

String readFile(File file) {
  return file.readAsStringSync();
}

Future<File> writeFile(String path, String content) async {
  final basePath = await getLocalDocsPath;
  final file = await File(basePath + path + '.json').create(recursive: true);

  logger.d('Created file ${file.path}');

  final result = await file.writeAsString(content);
  logger.d('Written file ${result.path}');

  return result;
}

Future<File> renameOrCreate(String oldPath, String newPath) async {
  final basePath = await getLocalDocsPath;
  final file = File(basePath + oldPath + '.json');
  if (await file.exists()) {
    final renamed = await file.rename(basePath + newPath + '.json');
    logger.d('Moved file ${file.path} -> ${renamed.path}');
    return renamed;
  }
  final newFile = await File(basePath + newPath + '.json').create();
  logger.d('Created file ${newFile.path}');

  return newFile;
}

void renameAndWriteFile(String oldPath, String newPath, String content) async {
  final file = await renameOrCreate(oldPath, newPath);
  file.writeAsString(content);
  logger.d('Written file ${file.path}');
}

void deleteFile(String path) async {
  final basePath = await getLocalDocsPath;
  final file = File(basePath + path + '.json');
  if (await file.exists()) {
    file.deleteSync();
    logger.d('Deleted file ${file.path}');
  }
}
