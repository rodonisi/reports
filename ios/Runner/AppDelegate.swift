import UIKit
import Flutter
import ObjectiveDropboxOfficial

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    DBClientsManager.handleRedirectURL(url) {authResult in
      if authResult!.isSuccess() {
        print("dropbox auth success")
      } else if authResult!.isCancel() {
        print("dropbox auth cancel")
      } else if authResult!.isError() {
        print("dropbox auth error \(authResult!.errorDescription)")
      }
    }
    return true
  }
}

