import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/models/preferences_model.dart';

Widget wrapWidgetMaterial({required Widget widget, ThemeData? theme}) {
  return MaterialApp(
    home: Localizations(
      delegates: AppLocalizations.localizationsDelegates,
      locale: Locale('en'),
      child: widget,
    ),
    theme: theme,
  );
}

Widget wrapWidgetScaffold({required Widget widget, ThemeData? theme}) {
  return wrapWidgetMaterial(
    widget: Scaffold(
      body: widget,
    ),
    theme: theme,
  );
}

Widget wrapProviders({required Widget widget}) {
  final appState = AppStateModel();
  final prefs = PreferencesModel();
  prefs.initialize();
  return wrapWidgetScaffold(
    widget: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: prefs),
      ],
      child: widget,
    ),
  );
}
