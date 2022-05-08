// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:reports/utilities/logger.dart';

// -----------------------------------------------------------------------------
// - Pages Enum
// -----------------------------------------------------------------------------

/// The pages that can be active from the main navigator.
enum Pages {
  reports,
  layouts,
  import,
  settings,
  statistics,
  drawer,
}

// -----------------------------------------------------------------------------
// - AppStateModel Implementation
// -----------------------------------------------------------------------------

/// The model of the main app state.
class AppStateModel extends ChangeNotifier {
  AppStateModel()
      : this._currentPage = Pages.reports,
        this._reportsListPath = '';

  Pages _currentPage;

  /// Get the current page.
  Pages get currentPage => _currentPage;

  /// Set the current page.
  set currentPage(Pages page) {
    _currentPage = page;
    logger.d("Current page: $_currentPage");
    notifyListeners();
  }

  String _reportsListPath;

  /// Get the path currently diplayed by the reports list.
  String get reportsListPath => _reportsListPath;

  /// Set the path currently displayed by the reports list.
  set reportsListPath(String path) {
    _reportsListPath = path;
    logger.d("Reports list path: $_reportsListPath");
    notifyListeners();
  }
}
