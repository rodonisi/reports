// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:reports/utilities/logger.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/common/report_structures.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// - PreferencesModel Implementation
// -----------------------------------------------------------------------------

class PreferencesModel extends ChangeNotifier {
  late SharedPreferences _prefs;
  String localDocsPath = '';

  PreferencesModel(SharedPreferences sharedPreferences) {
    _prefs = sharedPreferences;
  }

  Future<void> initialize() async {
    try {
      localDocsPath = (await getApplicationDocumentsDirectory()).path;
    } catch (e) {
      logger.e('Failed to get local docs path', e);
    }

    notifyListeners();
  }

  String getString(String key,
      {String defaultValue = '', bool ensureInitialized = false}) {
    final value = _prefs.getString(key);
    if (value == null) {
      if (ensureInitialized) {
        setString(key, defaultValue);
      }
      return defaultValue;
    }

    return value;
  }

  bool getBool(String key,
      {bool defaultValue = false, bool ensureInitialized = false}) {
    final value = _prefs.getBool(key);
    if (value == null) {
      if (ensureInitialized) {
        setBool(key, defaultValue);
      }
      return defaultValue;
    }

    return value;
  }

  int getInt(String key,
      {int defaultValue = 0, bool ensureInitialized = false}) {
    final value = _prefs.getInt(key);
    if (value == null) {
      if (ensureInitialized) {
        setInt(key, defaultValue);
      }
      return defaultValue;
    }

    return value;
  }

  Future<void> setString(String key, String value) async {
    logger.d('Setting string preference $key: $value');
    final saved = await _prefs.setString(key, value);
    if (!saved) throw Exception('Failed to store preference $key');
    notifyListeners();
  }

  Future<void> setBool(String key, bool value) async {
    logger.d('Setting boolean preference $key: $value');
    final saved = await _prefs.setBool(key, value);
    if (!saved) throw Exception('Failed to store preference $key');
    notifyListeners();
  }

  Future<void> setInt(String key, int value) async {
    logger.d('Setting integer preference $key: $value');
    final saved = await _prefs.setInt(key, value);
    if (!saved) throw Exception('Failed to store preference $key');
    notifyListeners();
  }
}
