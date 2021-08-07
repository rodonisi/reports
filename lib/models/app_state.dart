import 'package:flutter/material.dart';

/// The pages that can be active from the main navigator.
enum Pages { reports, layouts, settings }

/// The model of the main app state.
class AppStateModel extends ChangeNotifier {
  AppStateModel()
      : this._currentPage = Pages.reports,
        this._reportsListPath = '';

  Pages? _currentPage;
  Pages? get currentPage => _currentPage;
  set currentPage(Pages? page) {
    _currentPage = page;
    notifyListeners();
  }

  /// Get an index from the currently selected page.
  int getIndexFromPage() {
    switch (_currentPage) {
      case Pages.reports:
        return 0;
      case Pages.layouts:
        return 1;
      case Pages.settings:
        return 2;
      default:
        throw Exception('Invalid page');
    }
  }

  /// Set the current page from an integer index.
  void setPageFromIndex(int index) {
    switch (index) {
      case 0:
        currentPage = Pages.reports;
        break;
      case 1:
        currentPage = Pages.layouts;
        break;
      case 2:
        currentPage = Pages.settings;
        break;
      default:
        throw Exception('Invalid index');
    }
  }

  String _reportsListPath;
  String get reportsListPath => _reportsListPath;
  set reportsListPath(String path) {
    _reportsListPath = path;
    notifyListeners();
  }
}
