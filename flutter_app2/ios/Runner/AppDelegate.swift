import UIKit
import Flutter
import awesome_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // This function registers the desired plugins to be used within a notification background action
      SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in          
          SwiftAwesomeNotificationsPlugin.register(
            with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

//updated appdelegate file to prevent automatic backups
//check chat gpt for more info
/* import UIKit
import Flutter
import awesome_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // This function registers the desired plugins to be used within a notification background action
    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in          
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
    }
    
    excludeFromBackup() // Call the function to exclude directories from backup

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func excludeFromBackup() {
    let fileManager = FileManager.default
    let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let sharedPrefsURL = documentDirectoryURL.appendingPathComponent("Library/Preferences")
    
    do {
      let directoryEnumerator = fileManager.enumerator(at: documentDirectoryURL, includingPropertiesForKeys: nil)!
      
      for url in directoryEnumerator {
        guard let directoryURL = url as? URL else { continue }
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try directoryURL.setResourceValues(resourceValues)
      }
      
      // Exclude shared preferences directory
      var sharedPrefsResourceValues = URLResourceValues()
      sharedPrefsResourceValues.isExcludedFromBackup = true
      try sharedPrefsURL.setResourceValues(sharedPrefsResourceValues)
      
    } catch {
      print("Failed to exclude directories from backup: \(error)")
    }
  }
} */
