// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Save`
  String get buttonSave {
    return Intl.message(
      'Save',
      name: 'buttonSave',
      desc: 'Save button string',
      args: [],
    );
  }

  /// `Layouts`
  String get layoutsTitle {
    return Intl.message(
      'Layouts',
      name: 'layoutsTitle',
      desc: 'Layouts list view title',
      args: [],
    );
  }

  /// `Reports`
  String get reportsTitle {
    return Intl.message(
      'Reports',
      name: 'reportsTitle',
      desc: 'Reports list view title',
      args: [],
    );
  }

  /// `Backup to Dropbox`
  String get settingsDBBackup {
    return Intl.message(
      'Backup to Dropbox',
      name: 'settingsDBBackup',
      desc: 'Enable Dropbox backup option string',
      args: [],
    );
  }

  /// `Backup Location`
  String get settingsDBLocation {
    return Intl.message(
      'Backup Location',
      name: 'settingsDBLocation',
      desc: 'Dropbox backup location option string ',
      args: [],
    );
  }

  /// `Sign In`
  String get settingsSignIn {
    return Intl.message(
      'Sign In',
      name: 'settingsSignIn',
      desc: 'Dropbox sign in button string',
      args: [],
    );
  }

  /// `Sign Out`
  String get settingsSignOut {
    return Intl.message(
      'Sign Out',
      name: 'settingsSignOut',
      desc: 'Dropbox sign out button string',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: 'The settings view title\n',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'it'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
