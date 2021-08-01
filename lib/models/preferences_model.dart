import 'package:flutter/material.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/report_structures.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}

class PreferencesModel extends ChangeNotifier {
  late SharedPreferences _prefs;
  late String localDocsPath;
  bool loading = true;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    localDocsPath = await getLocalDocsPath;
    loading = false;

    notifyListeners();
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

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
    return getString(PreferenceKeys.layoutBaseName);
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
    return getString(PreferenceKeys.reportBaseName);
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

  Future<void> initializeString(String key, String value) async {
    if (_prefs.getString(key) == null) setString(key, value);
  }

  Future<void> initializeBool(String key, bool value) async {
    if (_prefs.getBool(key) == null) setBool(key, value);
  }

  Future<void> setString(String key, String value) async {
    final saved = await _prefs.setString(key, value);
    if (!saved) throw Exception('Failed to store preference $key');
    notifyListeners();
  }

  Future<void> setBool(String key, bool value) async {
    final saved = await _prefs.setBool(key, value);
    if (!saved) throw Exception('Failed to store preference $key');
    notifyListeners();
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

  /// Get the default name for a new report or layout synchronously based on the
  /// given settings.
  static String constructName(String name, bool hasDate, bool hasTime) {
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