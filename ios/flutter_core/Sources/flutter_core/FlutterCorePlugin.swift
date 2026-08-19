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
    case "getLocalizedCountryNames":
      result(FlutterCorePlugin.localizedCountryNames(from: call.arguments))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Cihazin ICU verisinden, verilen dile gore ulke adlarini dondurur.
  static func localizedCountryNames(from arguments: Any?) -> [String: String] {
    let args = arguments as? [String: Any]
    let languageCode = args?["languageCode"] as? String ?? Locale.current.identifier
    let isoCodes = args?["isoCodes"] as? [String] ?? []
    let locale = Locale(identifier: languageCode)
    var names: [String: String] = [:]
    for isoCode in isoCodes {
      // ICU adi bulunamazsa Dart tarafi kendi adini kullansin diye atlanir.
      guard let name = locale.localizedString(forRegionCode: isoCode), name != isoCode else { continue }
      names[isoCode] = name
    }
    return names
  }
}


