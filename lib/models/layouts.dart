// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/io.dart';

class LayoutsModel extends ChangeNotifier {
  LayoutsModel() {
    loadFromFiles();
  }

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

  void loadFromFiles() async {
    final layouts = await getLocalDirFiles(layoutsDirectory);
    for (var file in layouts) {
      add(ReportLayout.fromJson(readFile(file)));
    }
  }
}
