// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
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

Future<List<File>> getLocalDirFiles(String dirPath) async {
  List<File> files = [];
  final basePath = await getLocalDocsPath;
  final dir = Directory(basePath + dirPath);

  for (var entry in dir.listSync()) {
    if (entry is File) {
      files.add(entry);
      logger.d('Found file ${entry.path}');
    }
  }

  return files;
}

String readFile(File file) {
  return file.readAsStringSync();
}

Future<File> writeFile(String path, String content) async {
  final basePath = await getLocalDocsPath;
  final file = await File(basePath + path).create(recursive: true);
  return file.writeAsString(content);
}
