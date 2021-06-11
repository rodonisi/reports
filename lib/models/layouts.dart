// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/structures/report_structures.dart';

class LayoutsModel extends ChangeNotifier {
  final List<ReportLayout> _layouts = [];
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  List<ReportLayout> get layouts => _layouts;

  void add(ReportLayout layout) {
    _layouts.add(layout);
    _logger.d('Added layout: ${layout.name}');

    notifyListeners();
  }

  void remove(ReportLayout layout) {
    _layouts.remove(layout);
    _logger.d('Removed layout: ${layout.name}');

    notifyListeners();
  }

  void update(int index, ReportLayout layout) {
    _layouts[index] = layout;
    _logger.d('Updated layout: ${layout.name} at position $index');

    notifyListeners();
  }
}
