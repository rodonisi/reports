import 'package:flutter_test/flutter_test.dart';
import 'package:reports/models/app_state.dart';

void main() {
  late AppStateModel target;
  setUpAll(() {
    target = AppStateModel();
  });
  test('initialization', () {
    var expectedPage = Pages.reports;
    var expectedPath = '';

    expect(target.currentPage, expectedPage);
    expect(target.reportsListPath, expectedPath);
  });

  test('set currentPage', () {
    var expectedPage = Pages.layouts;
    var appState = AppStateModel();

    appState.currentPage = expectedPage;

    expect(appState.currentPage, expectedPage);
  });

  test('set reportsListPath', () {
    var expectedPath = 'test';

    target.reportsListPath = expectedPath;

    expect(target.reportsListPath, expectedPath);
  });
}
