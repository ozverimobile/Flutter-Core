import Flutter
import UIKit



public class FlutterCorePlugin: NSObject, FlutterPlugin {
  // EventChannel/MethodChannel handler'ının yaşam süresi boyunca ayakta kalması için
  // güçlü referans tutuyoruz.
  private static var screenRecordingDetector: ScreenRecordingDetector?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_core", binaryMessenger: registrar.messenger())
    let instance = FlutterCorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(SSProtectorFactory(messenger: registrar.messenger()), withId: "secure_image_viewer")
    screenRecordingDetector = ScreenRecordingDetector(messenger: registrar.messenger())
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


