// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:reports/common/rule_structures.dart';
import 'package:reports/utilities/logger.dart';
import 'package:reports/models/preferences_model.dart';

// -----------------------------------------------------------------------------
// - Constants
// -----------------------------------------------------------------------------
const String layoutsDirectoryPath = 'layouts';
const String reportsDirectoryPath = 'reports';
const String statsRulesPath = 'stats_rules.json';

abstract class ReportsExtensions {
  static const String report = ".report";
  static const String layout = ".layout";
}

// -----------------------------------------------------------------------------
// - IO Utilities
// -----------------------------------------------------------------------------

/// Compare FileSystemEntities by their paths
int fileSystemEntityComparator(FileSystemEntity a, FileSystemEntity b) {
  return a.path.compareTo(b.path);
}

/// Returns a sorted list of all files in the given directory.
List<File> getDirectoryList(Directory dir,
    {bool ignoreSystemDirectories = true, bool recursive = false}) {
  final list = dir.listSync(recursive: recursive);

  // Filter out directories
  final List<File> selected = list.whereType<File>().toList();

  // Filter out system files
  if (ignoreSystemDirectories)
    selected.removeWhere((File file) => p.basename(file.path).startsWith('.'));

  selected.sort(fileSystemEntityComparator);

  return selected;
}

/// Get the list of layouts stored in the local layouts directory.
List<File> getLayoutsList(BuildContext context) {
  final dir = context.read<PreferencesModel>().layoutsDirectory;
  return getDirectoryList(dir);
}

/// Get the recursive list of all reports stored in the local reports directory.
List<File> getReportsList(BuildContext context) {
  final dir = context.read<PreferencesModel>().reportsDirectory;
  return getDirectoryList(dir, recursive: true);
}

/// Get the locally stored custom statistics rules
File getStatsRulesFile(BuildContext context) {
  final dir = context.read<PreferencesModel>().defaultPath;
  return File(p.join(dir, statsRulesPath));
}

/// Get the list of all statistics rules stored in the local custom rules files.
List<Rule> getStatsRules(BuildContext context) {
  final file = getStatsRulesFile(context);
  if (!file.existsSync()) return [];

  return (jsonDecode(file.readAsStringSync()) as List<dynamic>)
      .map((e) => Rule.fromJson(e))
      .toList();
}

void _writeStatsRules(BuildContext context, List<Rule> rules) {
  final rulesFile = getStatsRulesFile(context);
  rulesFile.writeAsStringSync(jsonEncode(rules));
  logger.d('Wrote rules to file: ${rulesFile.path}');
}

/// Write the given rule to the statistics rules file.
void writeStatsRule(BuildContext context, Rule rule) {
  final rules = getStatsRules(context);

  final ruleIndex = rules.indexWhere((element) => element.id == rule.id);
  if (ruleIndex != -1) {
    rules[ruleIndex] = rule;
    logger.d('Updated rule: ${rule.id}');
  } else {
    rules.add(rule);
    logger.d('Added rule: ${rule.id}');
  }

  _writeStatsRules(context, rules);
}

/// Remove the given rule from the statistics rules file.
void removeStatsRule(BuildContext context, Rule rule) {
  final rules = getStatsRules(context);

  final ruleIndex = rules.indexWhere((element) => element.id == rule.id);
  if (ruleIndex != -1) {
    rules.removeAt(ruleIndex);
    logger.d('Removed rule: ${rule.id}');
    _writeStatsRules(context, rules);
  }
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

/// Copy the file stored in the source path to destination. Returns false if a
/// file already exists on destination.
bool copyFile(String source, String destination) {
  // Get file.
  final file = File(source);

  // Check if file exists
  if (File(destination).existsSync()) return false;

  // Copy the file to the destination.
  file.copy(destination);

  logger.d('Copied file $source to $destination');

  return true;
}

/// Get the name of the file the input path is pointing to.
String getFileName(String path) {
  return p.basename(path);
}

/// Get the name of the file the input path is pointing to, without the
/// extension.
String getFileNameWithoutExtension(String path) {
  return p.basenameWithoutExtension(path);
}

/// Get the extension of the file the input path is pointing to.
String getFileExtension(String path) {
  return p.extension(path);
}

/// Get the path of the file the input path is pointing to.
String getRelativePath(String path, {required String from}) {
  return p.relative(path, from: from);
}

// TODO: Rename to getDirectoryPath
/// Get the name of the directory the path is pointing to.
String getDirectoryName(String path) {
  return p.dirname(path);
}

// Split the path into its elements.
List<String> splitPathElements(String path) {
  return p.split(path);
}
