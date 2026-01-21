import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let shareChannel = FlutterMethodChannel(name: "com.dracin.app/share",
                                              binaryMessenger: controller.binaryMessenger)
    
    shareChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "share" {
        guard let args = call.arguments as? [String: Any],
              let text = args["text"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Text is null", details: nil))
          return
        }
        self.shareText(text: text, controller: controller)
        result(nil)
      } else if call.method == "openUrl" {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "URL is null", details: nil))
          return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func shareText(text: String, controller: UIViewController) {
    let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    controller.present(activityViewController, animated: true, completion: nil)
  }
}
