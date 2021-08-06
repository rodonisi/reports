// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/theme.dart';
import 'package:reports/home.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/models/preferences_model.dart';

void main() {
  // Only allow portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Dropbox.
  if (!Platform.isMacOS)
    Dropbox.init('Reports_test', 'upxehk1wmyf3a71', 'vo0cqtao0zl56oh');

  // Declare and initialize providers.
  final prefs = PreferencesModel();
  prefs.initialize();
  final appState = AppStateModel();

  // Run app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferencesModel>.value(value: prefs),
        ChangeNotifierProvider<AppStateModel>.value(value: appState)
      ],
      child: ReportsApp(),
    ),
  );
}

class ReportsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();

    // Just returna a progrss indicator if the preferences have not loaded yet.
    if (prefs.loading)
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );

    return GestureDetector(
      onTap: () {
        // Get current focus.
        final currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) currentFocus.focusedChild!.unfocus();
      },
      child: MaterialApp(
        title: 'Reports',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Home(),
      ),
    );
  }
}
