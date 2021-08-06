import 'package:flutter/material.dart';

/// The pages that can be active from the main navigator.
enum Pages { reports, layouts, settings }

/// The model of the main app state.
class AppStateModel extends ChangeNotifier {
  AppStateModel() : this._currentPage = Pages.reports, this._reportsListPath = '';

  Pages? _currentPage;
  Pages? get currentPage => _currentPage;
  set currentPage(Pages? page) {
    _currentPage = page;
    notifyListeners();
  }

  String _reportsListPath;
  String get reportsListPath => _reportsListPath;
  set reportsListPath(String path) {
    _reportsListPath = path;
    notifyListeners();
  }
}
