import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:reports/utilities/io_utils.dart';

class Defaults {
  static const bool layoutNameDate = false;
  static const bool layoutNameTime = false;
  static const bool reportNameDate = true;
  static const bool reportNameTime = true;
}

class PreferenceKeys {
  /// Boolean. Defines wheter dropbox backup is enabled.
  static const String dropboxEnabled = 'dropboxEnabled';

  /// Boolean. Whether a manual authorization has been performed. Does not
  /// guarantee the success of the authoriazion process.
  static const String dropboxAuthorized = 'dropboxIsAuthorized';

  /// String. The stored dropbox access token for direct authorization.
  static const String dropboxAccessToken = 'dropboxAccessToken';

  /// String. The base path for the dropbox backup.
  static const String dropboxPath = 'dropboxPath';

  /// String. The base name to be used for new reports.
  static const String reportBaseName = 'reportBaseName';

  /// Bool. Wether to include the date in the name for new reports.
  static const String reportNameDate = 'reportNameDate';

  /// Bool. Wether to include the time in the name for new reports.
  static const String reportNameTime = 'reportNameTime';

  /// String. The base name to be used for new layouts.
  static const String layoutBaseName = 'layoutBaseName';

  /// Bool. Wether to include the date in the name for new layouts.
  static const String layoutNameDate = 'layoutNameDate';

  /// Bool. Wether to include the time in the name for new layouts.
  static const String layoutNameTime = 'layoutNameTime';

  /// String. The default path where to store data.
  static const String defaultPath = 'defaultPath';

  /// Bool. Wheter the client is in read-only mode.
  static const String readerMode = 'readerMode';

  /// Int. The theme mode of the client;
  static const String themeMode = 'themeMode';

  /// Int. the accent color for the client.
  static const String accentColor = 'accentColor';

  /// Bool. Whether to show the statistics tab.
  static const String showStatistics = 'showStatistics';

  /// Bool. Whether to show statistics for each supported field.
  static const String showFieldStatistics = 'showFieldStatistics';

  /// Bool. Whether to show statistics for each supported field type.
  static const String showFieldTypeStatistics = 'showFieldTypeStatistics';

  /// Bool. Whether to show statistics for the custom rules.
  static const String showCustomRuleStatistitcs = 'showCustomRuleStatistitcs';
}

class ReportsColors {
  /// The list of valid accent colors.
  static final colors = const <MaterialColor>[
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.yellow,
  ];

  /// The list of names for the respective accent colors.
  static final colorNames = [
    'settings.appearance.colors.blue',
    'settings.appearance.colors.green',
    'settings.appearance.colors.purple',
    'settings.appearance.colors.red',
    'settings.appearance.colors.orange',
    'settings.appearance.colors.yellow',
  ];
}

extension ConvenienceAccessors on PreferencesModel {
  String get dropboxAccessToken {
    return getString(PreferenceKeys.dropboxAccessToken);
  }

  bool get dropboxAuthorized {
    return getBool(PreferenceKeys.dropboxAuthorized);
  }

  bool get dropboxEnabled {
    return getBool(PreferenceKeys.dropboxEnabled);
  }

  String get dropboxPath {
    return getString(PreferenceKeys.dropboxPath);
  }

  String get layoutBaseName {
    return getString(
      PreferenceKeys.layoutBaseName,
      defaultValue: 'keywords.capitalized.layout'.tr(),
      ensureInitialized: true,
    );
  }

  bool get layoutNameDate {
    return getBool(PreferenceKeys.layoutNameDate,
        defaultValue: Defaults.layoutNameDate);
  }

  bool get layoutNameTime {
    return getBool(PreferenceKeys.layoutNameTime,
        defaultValue: Defaults.layoutNameTime);
  }

  String get defaultLayoutName {
    return constructName(layoutBaseName, layoutNameDate, layoutNameTime);
  }

  String get reportBaseName {
    return getString(
      PreferenceKeys.reportBaseName,
      defaultValue: 'keywords.capitalized.report'.tr(),
      ensureInitialized: true,
    );
  }

  bool get reportNameDate {
    return getBool(PreferenceKeys.reportNameDate,
        defaultValue: Defaults.reportNameDate);
  }

  bool get reportNameTime {
    return getBool(PreferenceKeys.reportNameTime,
        defaultValue: Defaults.reportNameTime);
  }

  String get defaultReportName {
    return constructName(reportBaseName, reportNameDate, reportNameTime);
  }

  String get defaultPath {
    return getString(PreferenceKeys.defaultPath, defaultValue: localDocsPath);
  }

  Directory get reportsDirectory {
    return Directory(p.join(defaultPath, reportsDirectoryPath))
      ..createSync(recursive: true);
  }

  String get reportsPath {
    return reportsDirectory.path;
  }

  Directory get layoutsDirectory {
    return Directory(p.join(defaultPath, layoutsDirectoryPath))
      ..createSync(recursive: true);
  }

  String get layoutsPath {
    return layoutsDirectory.path;
  }

  bool get readerMode {
    return getBool(PreferenceKeys.readerMode, defaultValue: false);
  }

  int get accentColorValue {
    return getInt(PreferenceKeys.accentColor);
  }

  MaterialColor get accentColor {
    return ReportsColors.colors[accentColorValue];
  }

  int get themeModeValue {
    return getInt(
      PreferenceKeys.themeMode,
      defaultValue: ThemeMode.system.index,
    );
  }

  ThemeMode get themeMode {
    return ThemeMode.values[themeModeValue];
  }

  bool get showStatistics {
    return getBool(PreferenceKeys.showStatistics, defaultValue: true);
  }

  bool get showFieldStatistics {
    return getBool(PreferenceKeys.showFieldStatistics, defaultValue: true);
  }

  bool get showFieldTypeStatistics {
    return getBool(PreferenceKeys.showFieldTypeStatistics, defaultValue: true);
  }

  bool get showCustomRuleStatistitcs {
    return getBool(PreferenceKeys.showCustomRuleStatistitcs,
        defaultValue: true);
  }

  set dropboxAccessToken(String value) {
    setString(PreferenceKeys.dropboxAccessToken, value);
  }

  set dropboxAuthorized(bool value) {
    setBool(PreferenceKeys.dropboxAuthorized, value);
  }

  set dropboxEnabled(bool value) {
    setBool(PreferenceKeys.dropboxEnabled, value);
  }

  set dropboxPath(String value) {
    setString(PreferenceKeys.dropboxPath, value);
  }

  set layoutBaseName(String value) {
    setString(PreferenceKeys.layoutBaseName, value);
  }

  set layoutNameDate(bool value) {
    setBool(PreferenceKeys.layoutNameDate, value);
  }

  set layoutNameTime(bool value) {
    setBool(PreferenceKeys.layoutNameTime, value);
  }

  set reportBaseName(String value) {
    setString(PreferenceKeys.reportBaseName, value);
  }

  set reportNameDate(bool value) {
    setBool(PreferenceKeys.reportNameDate, value);
  }

  set reportNameTime(bool value) {
    setBool(PreferenceKeys.reportNameTime, value);
  }

  set defaultPath(String value) {
    setString(PreferenceKeys.defaultPath, value);
  }

  set readerMode(bool value) {
    setBool(PreferenceKeys.readerMode, value);
  }

  set themeMode(ThemeMode mode) {
    setInt(PreferenceKeys.themeMode, mode.index);
  }

  set accentColorValue(int value) {
    setInt(PreferenceKeys.accentColor, value);
  }

  set accentColor(MaterialColor color) {
    accentColorValue = ReportsColors.colors.indexOf(color);
  }

  set showStatistics(bool value) {
    setBool(PreferenceKeys.showStatistics, value);
  }

  set showFieldStatistics(bool value) {
    setBool(PreferenceKeys.showFieldStatistics, value);
  }

  set showFieldTypeStatistics(bool value) {
    setBool(PreferenceKeys.showFieldTypeStatistics, value);
  }

  set showCustomRuleStatistitcs(bool value) {
    setBool(PreferenceKeys.showCustomRuleStatistitcs, value);
  }
}

extension ConvenienceMethods on PreferencesModel {
  /// Get the default name for a new report or layout synchronously based on the
  /// given settings.
  String constructName(String name, bool hasDate, bool hasTime) {
    if (!name.endsWith(' ') && (hasDate || hasTime)) {
      name += ' ';
    }

    if (hasDate && hasTime) {
      return name +
          DateFieldFormats.getFormat(DateFieldFormats.dateTimeModeID)
              .format(DateTime.now());
    }

    if (hasDate)
      return name +
          DateFieldFormats.getFormat(DateFieldFormats.dateModeID)
              .format(DateTime.now());

    if (hasTime)
      return name +
          DateFieldFormats.getFormat(DateFieldFormats.timeModeID)
              .format(DateTime.now());

    return name;
  }
}
