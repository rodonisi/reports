import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:logger/logger.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/io.dart';

// -----------------------------------------------------------------------------
// - ReportsModel Class Declaration
// -----------------------------------------------------------------------------
class ReportsModel extends ChangeNotifier {
  ReportsModel() {
    loadFromFiles();
  }

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final List<String> _reports = [];

  List<String> get reports => _reports;

  void add(String report) {
    _reports.add(report);
    _logger.d('Added report: $report');

    notifyListeners();
  }

  void remove(String report) {
    _reports.remove(report);
    _logger.d('Removed report: $report');

    notifyListeners();
  }

  void update(int index, Report report) {
    _reports[index] = report.title;
    _logger.d('Updated layout: ${report.title} at position $index');

    notifyListeners();
  }

  void loadFromFiles() async {
    final reports = await getLocalDirFiles(reportsDirectory);
    for (var file in reports) add(p.basenameWithoutExtension(file.path));

    notifyListeners();
  }
}
