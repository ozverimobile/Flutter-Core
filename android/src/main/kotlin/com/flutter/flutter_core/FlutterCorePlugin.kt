package com.flutter.flutter_core

import androidx.annotation.NonNull
import com.huawei.hms.api.HuaweiApiAvailability
import android.content.Context

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterCorePlugin */
class FlutterCorePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var mContext: Context
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
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
      val availability = HuaweiApiAvailability.getInstance().isHuaweiMobileServicesAvailable(mContext,sdkVersion)
      result.success(availability)
    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    mContext = null
  }

}
