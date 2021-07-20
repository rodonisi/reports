// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/io.dart';
import 'package:reports/common/logger.dart';

/// Provider model for the layouts stored in the app.
class LayoutsModel extends ChangeNotifier {
  /// Empty initializer. Also loads any layout present in the layouts directory.
  LayoutsModel() {
    loadFromFiles();
  }

  final List<String> _layouts = [];

  /// Get the layouts list stored in the provider.
  List<String> get layouts => _layouts;

  /// Add a layout to the provider and notify its listeners.
  void add(String layout) {
    _layouts.add(layout);
    logger.d('Added layout: $layout');

    _layouts.sort();

    notifyListeners();
  }

  /// Remove a layout from the provider and notfiy its listeners.
  void remove(String layout) {
    _layouts.remove(layout);
    logger.d('Removed layout: $layout');

    notifyListeners();
  }

  /// Remove the layout at the given index and notify its listeners.
  void removeAt(int index) {
    logger.d('Removed layout ${_layouts[index]} at index $index');
    _layouts.removeAt(index);

    notifyListeners();
  }

  /// Update the layout at the given index.
  void update(int index, String layout) {
    _layouts[index] = layout;
    logger.d('Updated layout: $layout at position $index');

    _layouts.sort();

    notifyListeners();
  }

  /// Load the layouts stored in the layouts directory.
  void loadFromFiles() async {
    final layouts = await getLocalDirFiles(layoutsDirectory);
    for (var file in layouts) add(p.basenameWithoutExtension(file.path));

    _layouts.sort();

    notifyListeners();
  }
}
