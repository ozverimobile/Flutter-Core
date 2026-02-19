import Flutter
import UIKit



public class FlutterCorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_core", binaryMessenger: registrar.messenger())
    let instance = FlutterCorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(SSProtectorFactory(messenger: registrar.messenger()), withId: "secure_image_viewer")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}


