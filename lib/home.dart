// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/extensions/app_state_extensions.dart';
import 'package:reports/models/app_state_model.dart';
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
        if (constraints.maxWidth > DrawingConstants.mediumScreen)
          return _WideLayout(
              extend: constraints.maxWidth > DrawingConstants.largeScreen);

        return _NarrowLayout();
      },
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({Key? key, this.extend = false}) : super(key: key);
  final bool extend;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    return Scaffold(
      body: SideBarLayout(
        sidebar: MenuRail(extended: extend),
        body: appState.currentPageView,
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
      pages: [appState.currentMaterialPage],
      onPopPage: (route, result) {
        final page = route.settings as MaterialPage;

        if (page.key == ReportsList.valueKey ||
            page.key == LayoutsList.valueKey ||
            page.key == Settings.valueKey) appState.currentPage = Pages.drawer;

        return route.didPop(result);
      },
    );
  }
}
