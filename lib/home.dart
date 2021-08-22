// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/views/import_reports.dart';
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/settings.dart';
import 'package:reports/widgets/sidebar_layout.dart';

// -----------------------------------------------------------------------------
// - Home View Implementation
// -----------------------------------------------------------------------------

/// Displays the main page of the app. This adapts to the width of the window,
/// displaying either a navigable single-page layout, or a sidebar layout.
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500)
          return _WideLayout(extend: constraints.maxWidth > 900);

        return _NarrowLayout();
      },
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({Key? key, this.extend = false}) : super(key: key);
  final bool extend;

  Widget _getChildFromPage(Pages? page) {
    switch (page) {
      case Pages.reports:
        return ReportsList();
      case Pages.layouts:
        return LayoutsList();
      case Pages.import:
        return ImportView();
      case Pages.settings:
        return Settings();
      case null:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    return Scaffold(
      body: SideBarLayout(
        sidebar: MenuRail(extended: extend),
        body: _getChildFromPage(appState.currentPage),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    return Navigator(
      pages: [
        if (appState.currentPage == null)
          MaterialPage(key: MenuDrawer.valueKey, child: MenuDrawer())
        else if (appState.currentPage == Pages.reports)
          MaterialPage(key: ReportsList.valueKey, child: ReportsList())
        else if (appState.currentPage == Pages.layouts)
          MaterialPage(key: LayoutsList.valueKey, child: LayoutsList())
        else if (appState.currentPage == Pages.import)
          MaterialPage(key: ImportView.valueKey, child: ImportView())
        else if (appState.currentPage == Pages.settings)
          MaterialPage(key: Settings.valueKey, child: Settings())
      ],
      onPopPage: (route, result) {
        final page = route.settings as MaterialPage;

        if (page.key == ReportsList.valueKey ||
            page.key == LayoutsList.valueKey ||
            page.key == Settings.valueKey) appState.currentPage = null;

        return route.didPop(result);
      },
    );
  }
}
