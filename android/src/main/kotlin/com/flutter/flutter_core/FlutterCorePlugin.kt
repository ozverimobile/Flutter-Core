package com.flutter.flutter_core

import androidx.annotation.NonNull
import com.huawei.hms.api.HuaweiApiAvailability
import android.content.Context
import android.annotation.SuppressLint
import android.content.ContentResolver
import android.provider.Settings

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** FlutterCorePlugin */
class FlutterCorePlugin: FlutterPlugin, MethodCallHandler {
  private var mContext: Context? = null
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var contentResolver: ContentResolver

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    contentResolver = flutterPluginBinding.applicationContext.contentResolver
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_core")
    channel.setMethodCallHandler(this)
    mContext = flutterPluginBinding.applicationContext
  }


  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    else if (call.method == "getHuaweiApiAvailability") {
      val sdkVersion = android.os.Build.VERSION.SDK_INT
      val availability = HuaweiApiAvailability.getInstance().isHuaweiMobileServicesAvailable(mContext!!,sdkVersion)
      result.success(availability)
    }else if (call.method == "getAndroidId") {
      try {
        result.success(getAndroidId())
      } catch (e: Exception) {
        result.error("ERROR_GETTING_ID", "Failed to get Android ID", e.localizedMessage)
      }
    }
    else {
      result.notImplemented()
    }
  }

  @SuppressLint("HardwareIds")
  private fun getAndroidId(): String? {
    return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    mContext = null
  }


}
