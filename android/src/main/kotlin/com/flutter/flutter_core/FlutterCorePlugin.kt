package com.flutter.flutter_core // Paket adınızın doğru olduğundan emin olun

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.provider.Settings
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
// Huawei importunuzu buraya eklemeyi unutmayın
// import com.huawei.hms.api.HuaweiApiAvailability 

/** FlutterCorePlugin */
class FlutterCorePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private var mContext: Context? = null
    private var activity: Activity? = null // Aktivite referansını tutmak için değişken
    private lateinit var channel : MethodChannel
    private lateinit var contentResolver: ContentResolver

    // --- FlutterPlugin Metotları ---

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        contentResolver = flutterPluginBinding.applicationContext.contentResolver
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_core")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mContext = null
    }

    // --- ActivityAware Metotları (EKLENDİ) ---
    // Bu metotlar sayesinde activity ve window'a erişebileceğiz.

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    // --- MethodCallHandler ---

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        else if (call.method == "getHuaweiApiAvailability") {
            val sdkVersion = android.os.Build.VERSION.SDK_INT
            // Huawei kütüphanesi projenizde ekli varsayarak bu kodu koruyoruz:
            // val availability = HuaweiApiAvailability.getInstance().isHuaweiMobileServicesAvailable(mContext!!, sdkVersion)
            // result.success(availability)
            result.notImplemented() // Huawei importu yoksa hata vermemesi için kapattım, varsa açabilirsiniz.
        }
        else if (call.method == "getAndroidId") {
            try {
                result.success(getAndroidId())
            } catch (e: Exception) {
                result.error("ERROR_GETTING_ID", "Failed to get Android ID", e.localizedMessage)
            }
        }
        else if (call.method == "setSecure") {
            val enabled = call.argument<Boolean>("enabled") ?: false
            setSecure(enabled)
            result.success(null)
        }
        else {
            result.notImplemented()
        }
    }

    private fun getAndroidId(): String? {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
    }

    // --- Set Secure Düzeltmesi ---

    private fun setSecure(enabled: Boolean) {
        // Activity null kontrolü yapıyoruz
        val currentActivity = activity ?: return

        currentActivity.runOnUiThread {
            if (enabled) {
                currentActivity.window.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
                )
            } else {
                currentActivity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        }
    }
}