package com.flutter.flutter_core.integrity

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** `flutter_core/device_integrity` kanalı: Dart `CoreDeviceIntegrity` API'si ile [CoreDeviceIntegrityChecker] arasındaki köprü. */
internal class CoreDeviceIntegrityPluginDelegate(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "flutter_core/device_integrity")
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    init {
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Dosya sistemi, process ve soket kontrolleri ana thread'i bloklamasın.
            "check" -> executor.execute {
                try {
                    val findings = CoreDeviceIntegrityChecker(context).check()
                    main.post { result.success(findings) }
                } catch (e: Throwable) {
                    main.post { result.error("INTEGRITY_CHECK_FAILED", e.message, null) }
                }
            }
            else -> result.notImplemented()
        }
    }
}
