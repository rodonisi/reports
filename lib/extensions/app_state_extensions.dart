import 'package:flutter/material.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/views/import_reports.dart';
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/settings.dart';
import 'package:reports/views/statistics.dart';

extension ConvenienceAccessors on AppStateModel {
  /// Convenience accessor for the current page view widget.
  Widget get currentPageView {
    switch (currentPage) {
      case Pages.reports:
        return const ReportsList();
      case Pages.layouts:
        return const LayoutsList();
      case Pages.import:
        return ImportView();
      case Pages.settings:
        return const Settings();
      case Pages.statistics:
        return const StatisticsList();
      default:
        return Container();
    }
  }

  /// Convenience accessor for the current navigator [ValueKey].
  get currentValueKey {
    switch (currentPage) {
      case Pages.reports:
        return ReportsList.valueKey;
      case Pages.layouts:
        return LayoutsList.valueKey;
      case Pages.import:
        return ImportView.valueKey;
      case Pages.settings:
        return Settings.valueKey;
      case Pages.statistics:
        return StatisticsList.valueKey;
      default:
        return null;
    }
  }

  /// Convenience accessor for the current navigator [MaterialPage].
  MaterialPage get currentMaterialPage => MaterialPage(
        key: currentValueKey,
        child: currentPageView,
      );

  /// Convenience accessor for the index of the current page in the [Pages]
  /// enum.
  int get currentPageIndex => currentPage.index;

  /// Convenience setter for the current page from a legal index into the
  /// [Pages] enum.
  set currentPageIndex(int index) => currentPage = Pages.values[index];
}
