// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  await EasyLocalization.ensureInitialized();

  // Declare and initialize providers.
  final prefs = PreferencesModel();
  await prefs.initialize();
  final appState = AppStateModel();

  // Run app
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('it')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<PreferencesModel>.value(value: prefs),
          ChangeNotifierProvider<AppStateModel>.value(value: appState)
        ],
        child: ReportsApp(),
      ),
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

        // Unfocus on tapping anywhere outside the keyboard to hide it.
        if (!currentFocus.hasPrimaryFocus) currentFocus.focusedChild!.unfocus();
      },
      child: MaterialApp(
        title: 'Reports',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: prefs.accentColor,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: prefs.accentColor,
          brightness: Brightness.dark,
        ),
        themeMode: prefs.themeMode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: Home(),
      ),
    );
  }
}
