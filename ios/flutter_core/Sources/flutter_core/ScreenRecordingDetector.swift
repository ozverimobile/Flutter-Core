import Flutter
import UIKit

/// iOS tarafında ekran kaydı (screen recording / screen mirroring) durumunu
/// dinleyip Flutter'a aktaran sınıf.
///
/// - `FlutterEventChannel` üzerinden Flutter'a `Bool` (kayıt aktif mi?) yayını yapar.
/// - `FlutterMethodChannel` üzerinden anlık durumu sorgulamayı (`isRecording`) sağlar.
///
/// Flutter tarafı stream'i dinlemeye başladığında (`onListen`) native izleme açılır,
/// aboneliği iptal ettiğinde (`onCancel`) izleme kapanır. Böylece "manuel aç/kapat"
/// kontrolü doğrudan Flutter'dan yapılabilir.
///
/// Kapsanan senaryolar:
/// 1. Uygulama açıkken kayıt başlatıldığında -> `capturedDidChangeNotification` tetiklenir.
/// 2. Kayıt aktifken uygulama/dinleme açıldığında -> `onListen` anında mevcut durumu yayınlar.
/// 3. Uygulama arka plandayken kayıt başlatılıp tekrar öne alındığında ->
///    `didBecomeActiveNotification` ile durum yeniden kontrol edilip yayınlanır.
public final class ScreenRecordingDetector: NSObject {

    private let eventChannel: FlutterEventChannel
    private let methodChannel: FlutterMethodChannel

    private var eventSink: FlutterEventSink?
    private var isMonitoring = false
    private var lastReportedState: Bool?

    init(messenger: FlutterBinaryMessenger) {
        eventChannel = FlutterEventChannel(
            name: "flutter_core/screen_recording_events",
            binaryMessenger: messenger
        )
        methodChannel = FlutterMethodChannel(
            name: "flutter_core/screen_recording",
            binaryMessenger: messenger
        )
        super.init()

        eventChannel.setStreamHandler(self)
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Method Channel

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isRecording":
            result(isScreenCaptured())
        case "startMonitoring":
            startMonitoring()
            result(nil)
        case "stopMonitoring":
            stopMonitoring()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Capture State

    private func isScreenCaptured() -> Bool {
        // `isCaptured`; ekran kaydı, AirPlay yansıtması veya QuickTime kaydı aktifse true döner.
        return UIScreen.main.isCaptured
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(captureStateDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false

        NotificationCenter.default.removeObserver(
            self,
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Notification Callbacks

    @objc private func captureStateDidChange() {
        emitState()
    }

    @objc private func appDidBecomeActive() {
        // Uygulama arka plandayken başlatılan/durdurulan kayıtları yakalamak için
        // öne alındığında durumu yeniden gönderiyoruz.
        emitState(force: true)
    }

    private func emitState(force: Bool = false) {
        guard let sink = eventSink else { return }

        let current = isScreenCaptured()
        if !force, let last = lastReportedState, last == current {
            return
        }
        lastReportedState = current

        if Thread.isMainThread {
            sink(current)
        } else {
            DispatchQueue.main.async {
                sink(current)
            }
        }
    }
}

// MARK: - FlutterStreamHandler

extension ScreenRecordingDetector: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        lastReportedState = nil
        startMonitoring()
        // Dinleme başlar başlamaz mevcut durumu hemen bildir.
        emitState(force: true)
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopMonitoring()
        eventSink = nil
        lastReportedState = nil
        return nil
    }
}
