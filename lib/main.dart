// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reports/home.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/models/preferences_model.dart';

// -----------------------------------------------------------------------------
// - App Entry Point
// -----------------------------------------------------------------------------
void main() async {
  // Only allow portrait mode
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dropbox.
  if (!Platform.isMacOS)
    await Dropbox.init('Reports_test', 'upxehk1wmyf3a71', 'vo0cqtao0zl56oh');

  // Declare and initialize providers.
  final prefs = PreferencesModel();
  await prefs.initialize();
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

    return GestureDetector(
      onTap: () {
        // Get current focus.
        final currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) currentFocus.focusedChild!.unfocus();
      },
      child: MaterialApp(
        title: 'Reports',
        theme: ThemeData(
          primaryColor: Colors.white,
          primarySwatch: prefs.accentColor,
          accentColor: prefs.accentColor,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: prefs.accentColor,
          accentColor: prefs.accentColor,
          brightness: Brightness.dark,
        ),
        themeMode: prefs.themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Home(),
      ),
    );
  }
}
