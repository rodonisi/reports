import 'package:reports/common/report_structures.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DefaultNameType { layout, report }

/// Contains the statig key strings for the shared preferences.
class Preferences {
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
  static const bool reportNameDateDefault = true;

  /// Bool. Wether to include the time in the name for new reports.
  static const String reportNameTime = 'reportNameTime';
  static const bool reportNameTimeDefault = false;

  /// String. The base name to be used for new layouts.
  static const String layoutBaseName = 'layoutBaseName';

  /// Bool. Wether to include the date in the name for new layouts.
  static const String layoutNameDate = 'layoutNameDate';
  static const bool layoutNameDateDefault = false;

  /// Bool. Wether to include the time in the name for new layouts.
  static const String layoutNameTime = 'layoutNameTime';
  static const bool layoutNameTimeDefault = false;

  /// Get the default name for a new report or layout.
  static Future<String> getDefaultName(DefaultNameType type) async {
    final prefs = await SharedPreferences.getInstance();

    final name;
    final hasDate;
    final hasTime;
    if (type == DefaultNameType.layout) {
      name = prefs.getString(layoutBaseName) ?? 'Layout';
      hasDate = prefs.getBool(layoutNameDate) ?? reportNameDateDefault;
      hasTime = prefs.getBool(layoutNameTime) ?? reportNameTimeDefault;
    } else {
      name = prefs.getString(reportBaseName) ?? 'Report';
      hasDate = prefs.getBool(reportNameDate) ?? reportNameDateDefault;
      hasTime = prefs.getBool(reportNameTime) ?? reportNameTimeDefault;
    }

    return getDefaultNameSync(name, hasDate, hasTime);
  }

  /// Get the default name for a new report or layout synchronously based on the
  /// given settings.
  static String getDefaultNameSync(String name, bool hasDate, bool hasTime) {
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

  /// Get the default value for the given preference.
  static Object getDefault(String preference) {
    switch (preference) {
      case reportNameDate:
        return reportNameDateDefault;
      case reportNameTime:
        return reportNameTimeDefault;
      case layoutNameDate:
        return layoutNameDateDefault;
      case layoutNameTime:
        return layoutNameTimeDefault;
      default:
        throw ArgumentError.value(preference, 'invalid preference');
    }
  }
}
