import Flutter
import Foundation

/// `flutter_core/device_integrity` kanalı: Dart `CoreDeviceIntegrity` API'si ile [CoreDeviceIntegrityChecker] arasındaki köprü.
final class CoreDeviceIntegrityBridge {
  private let channel: FlutterMethodChannel
  private let queue = DispatchQueue(label: "flutter_core.device_integrity", qos: .userInitiated)

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "flutter_core/device_integrity", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "check":
      // Dosya ve soket kontrolleri ana thread'i bloklamasın.
      queue.async {
        let findings = CoreDeviceIntegrityChecker().check()
        DispatchQueue.main.async { result(findings) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
