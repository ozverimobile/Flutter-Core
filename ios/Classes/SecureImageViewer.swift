import UIKit
import SwiftUI
import Kingfisher
import Flutter

// MARK: - 1. Factory Sınıfı
class SSProtectorFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    // Flutter'dan gelen parametreleri (Map/List) decode etmek için standart codec
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return SSProtectorNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            messenger: messenger
        )
    }
}

// MARK: - 2. Platform View Sınıfı (Logic Fix'leri Burada)
class SSProtectorNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var channel: FlutterMethodChannel

    private var privacyOverlay: UIVisualEffectView?
    private var removeOverlayWorkItem: DispatchWorkItem?

    // ✅ Yeni: Viewer açıkken aktif olsun
    private var protectionEnabled: Bool = true
    private var observersInstalled: Bool = false

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        channel = FlutterMethodChannel(name: "com.cwa.ssprotector/view_\(viewId)", binaryMessenger: messenger)

        var imageUrls: [String] = []
        var headers: [String: String]? = nil

        if let params = args as? [String: Any] {
            if let urls = params["imageUrls"] as? [String] { imageUrls = urls }
            if let h = params["headers"] as? [String: String] { headers = h }
        }

        _view = UIView()
        super.init()

        // ✅ Kapanışta protection kapat
        let swiftUIView = SSProtector(
            imageUrls: imageUrls,
            onClose: { [weak self] in
                guard let self = self else { return }
                self.disablePrivacyProtection()          // 🔥 kritik
                self.channel.invokeMethod("onClose", arguments: nil)
            },
            headers: headers
        )

        let hostingController = UIHostingController(rootView: swiftUIView)
        _view = hostingController.view
        _view.frame = frame
        _view.backgroundColor = .clear

        enablePrivacyProtection() // ✅ observer'ları burada aç
    }

    deinit {
        disablePrivacyProtection(immediate: true)
    }

    func view() -> UIView { _view }

    // Flutter engine bazen dispose çağırır (cache/cleanup sırasında)
    // ✅ ObjC selector olarak görünür olsun diye @objc ekliyoruz.
    @objc func dispose() {
        disablePrivacyProtection(immediate: true)
    }

    // MARK: - Enable/Disable

    private func enablePrivacyProtection() {
        protectionEnabled = true
        setupLifecycleObserversIfNeeded()
    }

    private func disablePrivacyProtection(immediate: Bool = true) {
        protectionEnabled = false

        removeOverlayWorkItem?.cancel()
        removeOverlayWorkItem = nil

        removePrivacyOverlay(immediate: immediate)
        removeLifecycleObserversIfNeeded()
    }

    private func setupLifecycleObserversIfNeeded() {
        guard !observersInstalled else { return }
        observersInstalled = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func removeLifecycleObserversIfNeeded() {
        guard observersInstalled else { return }
        observersInstalled = false

        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - Lifecycle callbacks

    @objc private func appWillResignActive() {
        guard protectionEnabled else { return }   // ✅ viewer kapalıysa blur yok

        removeOverlayWorkItem?.cancel()
        removeOverlayWorkItem = nil

        showPrivacyOverlay()
    }

    @objc private func appDidBecomeActive() {
        guard protectionEnabled else { return }   // ✅ viewer kapalıysa dokunma

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if UIApplication.shared.applicationState == .active {
                self.removePrivacyOverlay(immediate: false)
            }
        }

        removeOverlayWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }

    private func showPrivacyOverlay() {
        // ✅ Mümkünse bu view’in window’u; değilse keyWindow
        let targetWindow = _view.window
            ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })

        guard let window = targetWindow else { return }

        if let existingOverlay = privacyOverlay {
            existingOverlay.frame = window.bounds
            existingOverlay.alpha = 1
            window.bringSubviewToFront(existingOverlay)
            return
        }

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let overlay = UIVisualEffectView(effect: blurEffect)
        overlay.frame = window.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.alpha = 1

        window.addSubview(overlay)
        privacyOverlay = overlay
    }

    private func removePrivacyOverlay(immediate: Bool) {
        guard let overlay = privacyOverlay else { return }

        if immediate {
            overlay.removeFromSuperview()
            privacyOverlay = nil
        } else {
            UIView.animate(withDuration: 0.2) {
                overlay.alpha = 0
            } completion: { [weak self] _ in
                guard let self = self,
                      let currentOverlay = self.privacyOverlay,
                      currentOverlay == overlay,
                      currentOverlay.alpha == 0 else { return }

                currentOverlay.removeFromSuperview()
                self.privacyOverlay = nil
            }
        }
    }
}

// MARK: - 3. Kingfisher Modifier
public final class AsyncAuthHeaderModifier: AsyncImageDownloadRequestModifier {
    private let extraHeaders: [String: String]?

    public init(headers: [String: String]? = nil) {
        self.extraHeaders = headers
    }
  
    public let onDownloadTaskStarted: (@Sendable (Kingfisher.DownloadTask?) -> Void)? = nil

    public func modified(for request: URLRequest) async -> URLRequest? {
        var r = request
        if let headers = extraHeaders, !headers.isEmpty {
            for (key, value) in headers {
                r.setValue(value, forHTTPHeaderField: key)
            }
        }
        return r
    }
}

// MARK: - 4. SwiftUI View (SSProtector)
// MARK: - 4. SwiftUI View (SSProtector)
struct SSProtector: View {
    let imageUrls: [String]
    var onClose: (() -> Void)?

    @State private var selection: Int = 0
    @State private var isPagingEnabled: Bool = true

    // --- Swipe-to-dismiss state ---
    @State private var dismissOffsetY: CGFloat = 0
    @State private var isDismissingDragActive: Bool = false

    init(
        imageUrls: [String] = [],
        onClose: (() -> Void)? = nil,
        headers: [String: String]? = nil
    ) {
        self.imageUrls = imageUrls
        self.onClose = onClose
      
        if headers != nil && KingfisherManager.shared.defaultOptions.isEmpty  {
            KingfisherManager.shared.defaultOptions = [.requestModifier(AsyncAuthHeaderModifier(headers: headers))]
        }
    }

    private var contentScale: CGFloat {
        let t = min(abs(dismissOffsetY) / 900, 1)
        return 1 - (t * 0.08)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {

            // Ana Resim Görüntüleyici Arka Planı (Karanlık Mod)
            Color.black
                .ignoresSafeArea()

            // CONTENT (TabView + pages)
            TabView(selection: $selection) {
                ForEach(imageUrls.indices, id: \.self) { index in
                    ZoomablePageImage(
                        urlString: imageUrls[index],
                        isPagingEnabled: $isPagingEnabled
                    )
                    .tag(index)
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(PagePagingController(isEnabled: $isPagingEnabled))

            // Swipe-to-dismiss
            .simultaneousGesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        guard isPagingEnabled else { return }
                        let dx = value.translation.width
                        let dy = value.translation.height
                        guard abs(dy) > abs(dx) * 1.2 else { return }

                        isDismissingDragActive = true
                        dismissOffsetY = dy
                    }
                    .onEnded { value in
                        guard isDismissingDragActive else { return }
                        isDismissingDragActive = false

                        let dx = value.translation.width
                        let dy = value.translation.height

                        guard abs(dy) > abs(dx) * 1.2 else {
                            withAnimation(.spring()) { dismissOffsetY = 0 }
                            return
                        }

                        let threshold: CGFloat = 140
                        if abs(dy) >= threshold {
                           onClose?()
                        } else {
                            withAnimation(.spring()) { dismissOffsetY = 0 }
                        }
                    }
            )
            .offset(y: dismissOffsetY)
            .scaleEffect(contentScale)
            .animation(
                .interactiveSpring(response: 0.25, dampingFraction: 0.9),
                value: dismissOffsetY
            )

            // Close Button
            if #available(iOS 26.0, *) {
                 Button {
                    onClose?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .padding(10)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .padding(.top, 30)
                .padding(.trailing, 20)
            } else {
                Button {
                    onClose?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .padding(10)
                        .foregroundColor(.white) // İkon rengi beyaz kalsın
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .padding(.top, 60)
                .padding(.trailing, 20)
            }
        }
        .onChange(of: isPagingEnabled) { newValue in
            if newValue == false {
                withAnimation(.spring()) {
                    dismissOffsetY = 0
                    isDismissingDragActive = false
                }
            }
        }

        // --- GÜVENLİK ---
        .mask {
            ScreenshotPreventerMask()
                .ignoresSafeArea()
        }
        .background {
            // BURASI DEĞİŞTİ:
            // "Not Allowed" ekranının arkasına açık renk (Beyaz) koyuyoruz.
            ZStack {
                Color.white.ignoresSafeArea() // Arka planı BEYAZ yaptık
                
                if #available(iOS 17.0, *) {
                    ContentUnavailableView(
                        "Görüntülenemez",
                        systemImage: "eye.slash",
                        description: Text("Güvenlik nedeniyle ekran görüntüsü alınamaz.")
                    )
                    // Arka plan beyaz olduğu için yazıları SİYAH yapıyoruz
                    .foregroundStyle(.black) 
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 34, weight: .semibold))
                        Text("Görüntülenemez")
                            .font(.headline)
                        Text("Güvenlik nedeniyle ekran görüntüsü alınamaz.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .opacity(0.8)
                    }
                    // Yazıları SİYAH yapıyoruz
                    .foregroundColor(.black)
                    .padding()
                }
            }
        }
    }
}

// MARK: - 5. Helper Structs (Public yaparak dosya erişimini garantiye alıyoruz)

struct ZoomablePageImage: View {
    let urlString: String
    @Binding var isPagingEnabled: Bool
    @State private var resetToken = UUID()

    var body: some View {
        ZoomableScrollImageView(
            urlString: urlString,
            resetToken: resetToken,
            onZoomChanged: { zoom in
                isPagingEnabled = zoom <= 1.01
            }
        )
        .background(Color.black)
        .onDisappear {
            resetToken = UUID()
            isPagingEnabled = true
        }
    }
}

struct ZoomableScrollImageView: UIViewRepresentable {
    let urlString: String
    let resetToken: UUID
    let onZoomChanged: (CGFloat) -> Void

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.zoomScale = 1
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.bouncesZoom = true
        scrollView.decelerationRate = .fast
        scrollView.contentInset = .zero

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        scrollView.addSubview(imageView)

        context.coordinator.scrollView = scrollView
        context.coordinator.imageView = imageView
        context.coordinator.onZoomChanged = onZoomChanged

        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        context.coordinator.load(urlString: urlString)
        context.coordinator.updatePanEnabled()

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.onZoomChanged = onZoomChanged

        if context.coordinator.lastResetToken != resetToken {
            context.coordinator.lastResetToken = resetToken
            context.coordinator.resetZoom(animated: false)
        }

        let newBounds = scrollView.bounds.size
        if context.coordinator.lastBoundsSize != newBounds {
            context.coordinator.lastBoundsSize = newBounds
            context.coordinator.layoutImageIfPossible()
        }

        context.coordinator.load(urlString: urlString)
        context.coordinator.updatePanEnabled()
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var scrollView: UIScrollView?
        weak var imageView: UIImageView?
        var onZoomChanged: ((CGFloat) -> Void)?
        var lastResetToken: UUID?
        var lastBoundsSize: CGSize = .zero
        private var loadedURL: String?

        func load(urlString: String) {
            guard loadedURL != urlString else { return }
            loadedURL = urlString
            guard let url = URL(string: urlString) else { return }

            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.imageView?.image = value.image
                        self.resetZoom(animated: false)
                        self.layoutImageIfPossible()
                        self.updatePanEnabled()
                    }
                case .failure: break
                }
            }
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContent(scrollView)
            onZoomChanged?(scrollView.zoomScale)
            updatePanEnabled()
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) { centerContent(scrollView) }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            if scale <= 1.01 {
                resetZoom(animated: true)
            } else {
                onZoomChanged?(scale)
            }
            updatePanEnabled()
        }

        func resetZoom(animated: Bool) {
            guard let sv = scrollView else { return }
            sv.setZoomScale(1, animated: animated)
            sv.setContentOffset(.zero, animated: animated)
            sv.contentInset = .zero
            centerContent(sv)
            onZoomChanged?(sv.zoomScale)
            updatePanEnabled()
        }

        func layoutImageIfPossible() {
            guard let sv = scrollView, let iv = imageView else { return }
            guard let img = iv.image else {
                iv.frame = CGRect(origin: .zero, size: sv.bounds.size)
                sv.contentSize = iv.frame.size
                centerContent(sv)
                return
            }

            let bounds = sv.bounds.size
            if bounds.width <= 0 || bounds.height <= 0 { return }

            let fitScale = min(bounds.width / img.size.width, bounds.height / img.size.height)
            let fittedSize = CGSize(width: img.size.width * fitScale, height: img.size.height * fitScale)

            iv.frame = CGRect(origin: .zero, size: fittedSize)
            sv.contentSize = fittedSize
            centerContent(sv)
        }

        private func centerContent(_ scrollView: UIScrollView) {
            guard let iv = imageView else { return }
            let boundsSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            let offsetX = max((boundsSize.width - contentSize.width) * 0.5, 0)
            let offsetY = max((boundsSize.height - contentSize.height) * 0.5, 0)
            iv.center = CGPoint(x: contentSize.width * 0.5 + offsetX, y: contentSize.height * 0.5 + offsetY)
        }

        func updatePanEnabled() {
            guard let sv = scrollView else { return }
            sv.panGestureRecognizer.isEnabled = sv.zoomScale > 1.01
        }

        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard let sv = scrollView else { return }
            if sv.zoomScale > 1.01 {
                resetZoom(animated: true)
                return
            }
            let targetScale: CGFloat = 3
            let point = recognizer.location(in: imageView)
            let zoomRect = zoomRect(for: targetScale, center: point, in: sv)
            sv.zoom(to: zoomRect, animated: true)
            onZoomChanged?(targetScale)
            updatePanEnabled()
        }

        private func zoomRect(for scale: CGFloat, center: CGPoint, in scrollView: UIScrollView) -> CGRect {
            let size = CGSize(width: scrollView.bounds.size.width / scale, height: scrollView.bounds.size.height / scale)
            let origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
            return CGRect(origin: origin, size: size)
        }
    }
}

struct PagePagingController: UIViewRepresentable {
    @Binding var isEnabled: Bool
    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.isUserInteractionEnabled = false
        return v
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            var current: UIView? = uiView.superview
            while let view = current {
                if let scroll = view as? UIScrollView {
                    scroll.isScrollEnabled = isEnabled
                    scroll.panGestureRecognizer.isEnabled = isEnabled
                    break
                }
                current = view.superview
            }
        }
    }
}

struct ScreenshotPreventerMask: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UITextField()
        view.isSecureTextEntry = true
        view.isUserInteractionEnabled = false
        if let autoHideLayer = findAutoHideLayer(view: view) {
            autoHideLayer.backgroundColor = UIColor.white.cgColor
        } else {
            view.layer.sublayers?.last?.backgroundColor = UIColor.white.cgColor
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    private func findAutoHideLayer(view: UIView) -> CALayer? {
        view.layer.sublayers?.first { $0.delegate.debugDescription.contains("UITextLayoutCanvasView") }
    }
}