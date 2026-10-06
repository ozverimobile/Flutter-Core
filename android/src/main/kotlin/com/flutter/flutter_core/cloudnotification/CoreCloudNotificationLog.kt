package com.flutter.flutter_core.cloudnotification

import android.util.Log

/** OneSignal ile aynı seviye sırası: none=0, fatal=1, error=2, warn=3, info=4, debug=5, verbose=6. */
internal object CoreCloudNotificationLog {
    private const val TAG = "CoreCloudNotification"

    @Volatile
    var level = 3

    fun e(message: String, error: Throwable? = null) {
        if (level >= 2) Log.e(TAG, message, error)
    }

    fun w(message: String) {
        if (level >= 3) Log.w(TAG, message)
    }

    fun i(message: String) {
        if (level >= 4) Log.i(TAG, message)
    }

    fun d(message: String) {
        if (level >= 5) Log.d(TAG, message)
    }
}
