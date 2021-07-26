import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
