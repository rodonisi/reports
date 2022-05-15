import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/extensions/app_state_extensions.dart';
import 'package:reports/models/app_state_model.dart';
import 'package:reports/views/import_reports.dart';
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/settings.dart';
import 'package:reports/views/statistics.dart';

void main() {
  late AppStateModel target;
  setUpAll(() {
    target = AppStateModel();
  });

  group('get currentPageIndex', () {
    for (var element in Pages.values) {
      test(element.name, () {
        target.currentPage = element;
        expect(target.currentPageIndex, element.index);
      });
    }
  });

  group('set currentPageIndex', () {
    for (var element in Pages.values) {
      test(element.name, () {
        target.currentPageIndex = element.index;
        expect(target.currentPage, element);
      });
    }
  });

  group('get currentValueKey', () {
    test('reports', () {
      target.currentPage = Pages.reports;
      expect(target.currentValueKey, ReportsList.valueKey);
    });
    test('layouts', () {
      target.currentPage = Pages.layouts;
      expect(target.currentValueKey, LayoutsList.valueKey);
    });

    test('import', () {
      target.currentPage = Pages.import;
      expect(target.currentValueKey, ImportView.valueKey);
    });

    test('settings', () {
      target.currentPage = Pages.settings;
      expect(target.currentValueKey, Settings.valueKey);
    });

    test('statistics', () {
      target.currentPage = Pages.statistics;
      expect(target.currentValueKey, StatisticsList.valueKey);
    });

    test('default', () {
      target.currentPage = Pages.drawer;
      expect(target.currentValueKey, null);
    });
  });

  group('get currentPageView', () {
    test('reports', () {
      target.currentPage = Pages.reports;
      expect(target.currentPageView, isInstanceOf<ReportsList>());
    });

    test('layouts', () {
      target.currentPage = Pages.layouts;
      expect(target.currentPageView, isInstanceOf<LayoutsList>());
    });

    test('import', () {
      target.currentPage = Pages.import;
      expect(target.currentPageView, isInstanceOf<ImportView>());
    });

    test('settings', () {
      target.currentPage = Pages.settings;
      expect(target.currentPageView, isInstanceOf<Settings>());
    });

    test('statistics', () {
      target.currentPage = Pages.statistics;
      expect(target.currentPageView, isInstanceOf<StatisticsList>());
    });

    test('default', () {
      target.currentPage = Pages.drawer;
      expect(target.currentPageView, isInstanceOf<Container>());
    });
  });

  group('get currentMaterialPage', () {
    test('reports', () {
      target.currentPage = Pages.reports;
      var expectedValueKey = ReportsList.valueKey;

      expect(target.currentMaterialPage.key, expectedValueKey);
      expect(target.currentMaterialPage.child, isInstanceOf<ReportsList>());
    });

    test('layouts', () {
      target.currentPage = Pages.layouts;
      var expectedValueKey = LayoutsList.valueKey;

      expect(target.currentMaterialPage.key, expectedValueKey);
      expect(target.currentMaterialPage.child, isInstanceOf<LayoutsList>());
    });

    test('import', () {
      target.currentPage = Pages.import;
      var expectedValueKey = ImportView.valueKey;
      expect(target.currentMaterialPage.key, expectedValueKey);
      expect(target.currentMaterialPage.child, isInstanceOf<ImportView>());
    });

    test('settings', () {
      target.currentPage = Pages.settings;
      var expectedValueKey = Settings.valueKey;
      expect(target.currentMaterialPage.key, expectedValueKey);
      expect(target.currentMaterialPage.child, isInstanceOf<Settings>());
    });

    test('statistics', () {
      target.currentPage = Pages.statistics;
      var expectedValueKey = StatisticsList.valueKey;
      expect(target.currentMaterialPage.key, expectedValueKey);
      expect(target.currentMaterialPage.child, isInstanceOf<StatisticsList>());
    });

    test('drawer', () {
      target.currentPage = Pages.drawer;
      ValueKey? expectedValueKey;
      expect(target.currentMaterialPage.key, expectedValueKey);
      expect(target.currentMaterialPage.child, isInstanceOf<Container>());
    });
  });
}
