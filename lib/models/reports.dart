// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/logger.dart';

// -----------------------------------------------------------------------------
// - ReportsModel Class Declaration
// -----------------------------------------------------------------------------

/// Provider model for the reports stored in the app.
class ReportsModel extends ChangeNotifier {
  /// Empty initializer. Also loads all the reports stored in the reports
  /// directory
  ReportsModel() {
    loadFromFiles();
  }

  final List<String> _reports = [];

  /// Get the reports list stored in the provider.
  List<String> get reports => _reports;

  /// Add a report to the provider and notify the listeners.
  void add(String report) {
    _reports.add(report);
    logger.d('Added report: $report');

    notifyListeners();
  }

  /// Remove a report from the provider and notify the listeners.
  void remove(String report) {
    _reports.remove(report);
    logger.d('Removed report: $report');

    notifyListeners();
  }

  /// Update an existing report contained in the provider.
  void update(int index, Report report) {
    _reports[index] = report.title;
    logger.d('Updated layout: ${report.title} at position $index');

    notifyListeners();
  }

  /// Load the reports stored in the respective directory in the provider.
  void loadFromFiles() async {
    final reports = await getLocalDirFiles(reportsDirectory);
    for (var file in reports) add(p.basenameWithoutExtension(file.path));

    notifyListeners();
  }
}
