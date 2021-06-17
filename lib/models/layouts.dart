// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/logger.dart';

/// Provider model for the layouts stored in the app.
class LayoutsModel extends ChangeNotifier {
  /// Empty initializer. Also loads any layout present in the layouts directory.
  LayoutsModel() {
    loadFromFiles();
  }

  final List<ReportLayout> _layouts = [];

  /// Get the layouts list stored in the provider.
  List<ReportLayout> get layouts => _layouts;

  /// Add a layout to the provider and notify its listeners.
  void add(ReportLayout layout) {
    _layouts.add(layout);
    logger.d('Added layout: ${layout.name}');

    notifyListeners();
  }

  /// Remove a layout from the provider and notfiy its listeners.
  void remove(ReportLayout layout) {
    _layouts.remove(layout);
    logger.d('Removed layout: ${layout.name}');

    notifyListeners();
  }

  /// Update the layout at the given index.
  void update(int index, ReportLayout layout) {
    _layouts[index] = layout;
    logger.d('Updated layout: ${layout.name} at position $index');

    notifyListeners();
  }

  /// Load the layouts stored in the layouts directory.
  void loadFromFiles() async {
    final layouts = await getLocalDirFiles(layoutsDirectory);
    for (var file in layouts) add(ReportLayout.fromJSON(readFile(file)));

    notifyListeners();
  }
}
