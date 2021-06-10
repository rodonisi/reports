import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:logger/logger.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/structures/report_structures.dart';

// -----------------------------------------------------------------------------
// - ReportsModel Class Declaration
// -----------------------------------------------------------------------------
class ReportsModel extends ChangeNotifier {
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final List<Report> _reports = [];

  List<Report> get reports => _reports;

  void add(Report report) {
    _reports.add(report);
    _logger.d('Added report: ${report.title}');

    notifyListeners();
  }

  void remove(Report report) {
    _reports.remove(report);
    _logger.d('Removed report: ${report.title}');

    notifyListeners();
  }

  void update(int index, Report report) {
    _reports[index] = report;
    _logger.d('Updated layout: ${report.title} at position $index');

    notifyListeners();
  }
}
