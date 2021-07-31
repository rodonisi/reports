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
import 'package:reports/common/routes.dart';
import 'package:reports/models/preferences_model.dart';

void main() {
  // Only allow portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Dropbox.
  if (!Platform.isMacOS)
    Dropbox.init('Reports_test', 'upxehk1wmyf3a71', 'vo0cqtao0zl56oh');

  // Run app
  runApp(
    ChangeNotifierProvider<PreferencesModel>(
      create: (context) {
        final model = PreferencesModel();
        // Initialize preferences provider.
        model.initialize();
        return model;
      },
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
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
        initialRoute: '/reports',
        routes: routes,
      ),
    );
  }
}
