package com.flutter.flutter_core.cloudnotification

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * Push backend'inin mobil uç noktaları; hepsi `{baseUrl}/api/v1/apps/{appId}` altında ve
 * kimlik doğrulama istemez. PATCH gerektiği için HttpURLConnection yerine OkHttp kullanılır.
 * Çağrılar bloklayıcıdır, [CoreCloudNotification]'un seri iş kuyruğundan yapılır.
 */
internal class CoreCloudNotificationApi(val endpoint: String) {
    sealed class Result {
        class Ok(val code: Int, val body: String) : Result()

        /** [code] null ise istek sunucuya ulaşamadı (ağ hatası). */
        class Fail(val code: Int?, val message: String, val retryAfterSeconds: Int? = null) : Result() {
            /** Sonra tekrar denenmeli mi: ağ hatası, 429 ve 5xx. */
            val retryable: Boolean get() = code == null || code == 429 || code >= 500
        }
    }

    fun send(method: String, path: String, body: JSONObject?): Result {
        val request = Request.Builder()
            .url("$endpoint/$path")
            .method(method, (body?.toString() ?: "").toRequestBody(JSON))
            .build()
        return try {
            http.newCall(request).execute().use { response ->
                val text = response.body?.string().orEmpty()
                if (response.isSuccessful) {
                    Result.Ok(response.code, text)
                } else {
                    Result.Fail(response.code, "HTTP ${response.code} $method $path $text", response.header("Retry-After")?.trim()?.toIntOrNull())
                }
            }
        } catch (e: IOException) {
            Result.Fail(null, "$method $path: $e")
        }
    }

    companion object {
        private val JSON = "application/json; charset=utf-8".toMediaType()
        private val http = OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .callTimeout(20, TimeUnit.SECONDS)
            .build()

        fun endpoint(baseUrl: String?, appId: String?): String? {
            if (baseUrl.isNullOrBlank() || appId.isNullOrBlank()) return null
            val base = baseUrl.trim().trimEnd('/')
            if (!base.startsWith("http://") && !base.startsWith("https://")) return null
            return "$base/api/v1/apps/${appId.trim()}"
        }
    }
}
