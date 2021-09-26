import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/app_state.dart';
import 'package:reports/models/preferences_model.dart';

/// Wrap a widget with providers for the reports models.
class WrapProviders extends StatelessWidget {
  WrapProviders({Key? key, required this.widget, this.preferencesModel})
      : super(key: key);

  final Widget widget;
  final PreferencesModel? preferencesModel;

  @override
  Widget build(BuildContext context) {
    var model = preferencesModel ?? PreferencesModel();

    return WrapLocalized(
      widget: MultiProvider(
        providers: [
          ChangeNotifierProvider<PreferencesModel>.value(
            value: model,
          ),
          ChangeNotifierProvider<AppStateModel>(
            create: (context) => AppStateModel(),
          ),
        ],
        child: widget,
      ),
    );
  }
}

/// Wrap a widget with an EasyLocalization to enable testing localized widgets.
class WrapLocalized extends StatelessWidget {
  const WrapLocalized({Key? key, this.theme, required this.widget})
      : super(key: key);

  final ThemeData? theme;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
        supportedLocales: [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        child: WrapApp(
          widget: widget,
        ));
  }
}

/// Wrap with a widget with a MaterialApp and Material. If present, localization
/// delegates and locales are also declared.
class WrapApp extends StatelessWidget {
  const WrapApp({Key? key, required this.widget}) : super(key: key);

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: EasyLocalization.of(context)?.locale,
      supportedLocales: EasyLocalization.of(context)?.supportedLocales ??
          const [Locale('en')],
      localizationsDelegates: EasyLocalization.of(context)?.delegates,
      home: Material(
        child: widget,
      ),
    );
  }
}
