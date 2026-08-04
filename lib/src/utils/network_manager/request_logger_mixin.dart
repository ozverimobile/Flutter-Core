import 'dart:convert';

import 'package:flutter_core/flutter_core.dart';

const _divider = '─────────────────────────────────────────────────────────────';

mixin class RequestLoggerMixin {
  String _buildQueryParamatersString(BaseModel<dynamic>? queryParameters) {
    final queryParamatersMap = queryParameters?.toJson();
    return queryParamatersMap?.keys.map((key) => '&$key=${queryParamatersMap[key]}').join() ?? '';
  }

  String _prettyJson(Object? value) {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(value);
    } catch (_) {
      return jsonEncode(value, toEncodable: (unEncodable) => 'Unencodable value of type ->${unEncodable.runtimeType}<-');
    }
  }

  LogColors _colorForResponseTime(int responseTime) {
    if (responseTime < 300) return LogColors.green;
    if (responseTime < 1000) return LogColors.yellow;
    return LogColors.red;
  }

  void logRequestInfo({
    required String requestUrl,
    required RequestType type,
    BaseModel<dynamic>? data,
    FormData? dioFormData,
    BaseModel<dynamic>? queryParameters,
    String? pathSuffix,
    Map<String, dynamic>? headers,
  }) {
    final queryParamatersString = _buildQueryParamatersString(queryParameters);

    final requestLog =
        """
🟡 REQUEST
$_divider
Url        : $requestUrl${pathSuffix ?? ''}$queryParamatersString
Method     : ${type.name}
DateTime   : ${DateTime.now().toIso8601String()}
Headers    : $headers
Data       : ${_prettyJson(data?.toJson())}
DioFormData: ${dioFormData?.fields} ${dioFormData?.files}
$_divider""";
    CoreLogger.log(requestLog, color: LogColors.yellow);
  }

  void logResponseInfo({
    required Response<dynamic> response,
    required int responseTime,
    required String requestUrl,
    BaseModel<dynamic>? queryParameters,
    String? pathSuffix,
  }) {
    final queryParamatersString = _buildQueryParamatersString(queryParameters);

    final responseLog =
        """
🟢 RESPONSE
$_divider
Url        : $requestUrl${pathSuffix ?? ''}$queryParamatersString
DateTime   : ${DateTime.now().toIso8601String()}
Duration   : $responseTime ms
StatusCode : ${response.statusCode} ${response.statusMessage ?? ''}
Headers    : ${response.requestOptions.headers}
Data       : ${_prettyJson(response.data)}
$_divider""";
    CoreLogger.log(responseLog, color: _colorForResponseTime(responseTime));
  }

  void logErrorResponseInfo({
    required int? statusCode,
    required Object error,
    required String requestUrl,
    BaseModel<dynamic>? queryParameters,
    String? pathSuffix,
  }) {
    final queryParamatersString = _buildQueryParamatersString(queryParameters);
    final errorResponse = error is DioException ? error.response : null;

    final errorResponseLog =
        """
🔴 REQUEST ERROR
$_divider
Url            : $requestUrl${pathSuffix ?? ''}$queryParamatersString
StatusCode     : $statusCode
StatusMessage  : ${errorResponse?.statusMessage ?? ''}
Error          : $error
Data           : ${errorResponse != null ? _prettyJson(errorResponse.data) : ''}
$_divider""";
    CoreLogger.log(errorResponseLog, color: LogColors.red);
  }
}
