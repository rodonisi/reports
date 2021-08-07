import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/settings.dart';
import 'package:reports/widgets/sidebar_layout.dart';

/// Displays the main page of the app. This adapts to the width of the window,
/// displaying either a navigable single-page layout, or a sidebar layout.
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500)
          return _WideLayout(extend: constraints.maxWidth > 800);

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
        return Reports();
      case Pages.layouts:
        return Layouts();
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
          MaterialPage(key: Reports.valueKey, child: Reports())
        else if (appState.currentPage == Pages.layouts)
          MaterialPage(key: Layouts.valueKey, child: Layouts())
        else if (appState.currentPage == Pages.settings)
          MaterialPage(key: Settings.valueKey, child: Settings())
      ],
      onPopPage: (route, result) {
        final page = route.settings as MaterialPage;

        if (page.key == Reports.valueKey ||
            page.key == Layouts.valueKey ||
            page.key == Settings.valueKey) appState.currentPage = null;

        return route.didPop(result);
      },
    );
  }
}
