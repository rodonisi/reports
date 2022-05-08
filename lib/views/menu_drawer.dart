// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/extensions/app_state_extensions.dart';
import 'package:reports/models/app_state_model.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/extensions/preferences_model_extensions.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/widgets/container_tile.dart';

/// Displays the menu navigator as a navigation rail.
class MenuRail extends StatelessWidget {
  const MenuRail({Key? key, this.extended = false}) : super(key: key);

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateModel>();

    return NavigationRail(
      extended: extended,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(ReportsIcons.report),
          label: Text('keywords.capitalized.reports').tr(),
        ),
        NavigationRailDestination(
          icon: const Icon(ReportsIcons.layout),
          label: Text('keywords.capitalized.layouts').tr(),
        ),
        // TODO: Find a way to hide when disabled.
        NavigationRailDestination(
          icon: const Icon(Icons.poll_outlined),
          label: Text('keywords.capitalized.statistics').tr(),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.save_alt),
          label: Text('import.import').tr(),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings),
          label: Text('settings.settings').tr(),
        ),
      ],
      selectedIndex: state.currentPageIndex,
      onDestinationSelected: (index) {
        state.currentPageIndex = index;
      },
    );
  }
}

// -----------------------------------------------------------------------------
// - MenuDrawer Widget Implementation
// -----------------------------------------------------------------------------

/// Creates the menu drawer for the app.
class MenuDrawer extends StatelessWidget {
  static const String routeName = '/';
  static const ValueKey valueKey = ValueKey('MenuDrawer');
  const MenuDrawer({Key? key}) : super(key: key);

  Widget _getSeparator() {
    return const SizedBox(
      height: 32.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppStateModel>();
    final prefs = context.read<PreferencesModel>();

    return Scaffold(
      body: SafeArea(
        top: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: DrawingConstants.smallPadding,
            vertical: DrawingConstants.mediumPadding,
          ),
          children: [
            ContainerTile(
              title: Text('keywords.capitalized.reports').tr(),
              leading: const Icon(ReportsIcons.report),
              selected: appState.currentPage == Pages.reports,
              onTap: () =>
                  context.read<AppStateModel>().currentPage = Pages.reports,
            ),
            ContainerTile(
              title: Text('keywords.capitalized.layouts').tr(),
              leading: const Icon(ReportsIcons.layout),
              selected: appState.currentPage == Pages.layouts,
              onTap: () =>
                  context.read<AppStateModel>().currentPage = Pages.layouts,
            ),
            if (prefs.showStatistics)
              ContainerTile(
                title: Text('keywords.capitalized.statistics').tr(),
                leading: const Icon(Icons.poll_outlined),
                selected: appState.currentPage == Pages.statistics,
                onTap: () => context.read<AppStateModel>().currentPage =
                    Pages.statistics,
              ),
            _getSeparator(),
            ListTile(
              title: Text('import.import').tr(),
              leading: const Icon(Icons.save_alt),
              selected: appState.currentPage == Pages.import,
              onTap: () => appState.currentPage = Pages.import,
            ),
            _getSeparator(),
            ContainerTile(
              title: Text('settings.settings').tr(),
              leading: const Icon(Icons.settings),
              selected: appState.currentPage == Pages.settings,
              onTap: () =>
                  context.read<AppStateModel>().currentPage = Pages.settings,
            ),
          ],
        ),
      ),
    );
  }
}
