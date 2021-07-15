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
}
