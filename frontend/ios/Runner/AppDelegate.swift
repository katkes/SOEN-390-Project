import UIKit
import Flutter
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Configure Google Sign-In
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Google Sign-In restore error: \(error.localizedDescription)")
            } else {
                print("Google Sign-In restored: \(user?.profile?.email ?? "No user")")
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Handle URL callback from Google Sign-In
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
