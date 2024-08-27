import 'dart:convert';

import 'package:flutter_core/flutter_core.dart';

mixin class RequestLoggerMixin {
  void logRequestInfo({
    required String requestUrl,
    required RequestType type,
    BaseModel<dynamic>? data,
    FormData? dioFormData,
    BaseModel<dynamic>? queryParameters,
    String? pathSuffix,
    Map<String, dynamic>? headers,
  }) {
    final queryParamatersMap = queryParameters?.toJson();
    final queryParamatersString = queryParamatersMap?.keys.map((key) => '&$key=${queryParamatersMap[key]}').join() ?? '';

    final requestLog = """
REQUEST
->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->
Request Url: $requestUrl${pathSuffix ?? ''}$queryParamatersString,
Method: ${type.name}
DateTime: ${DateTime.now().toIso8601String()}
Request Data: ${jsonEncode(data?.toJson(), toEncodable: (Object? unEncodable) => "Unencodable value of type ->${unEncodable.runtimeType}<-")}
Request DioFormData: ${dioFormData?.fields} ${dioFormData?.files}
Headers: $headers
->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->""";
    CoreLogger.log(requestLog, color: LogColors.yellow);
  }

  void logResponseInfo({
    required Response<dynamic> response,
    required int responseTime,
    required String requestUrl,
  }) {
    final responseLog = """
RESPONSE
<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-
Request Url: $requestUrl
DateTime: ${DateTime.now().toIso8601String()}
Response Time: $responseTime milliseconds
Headers: ${response.requestOptions.headers}
Response Status Code: ${response.statusCode}
Response Status Message: ${response.statusMessage ?? "null"}
Response Data: ${jsonEncode(response.data, toEncodable: (Object? unEncodable) => "Unencodable value of type ->${unEncodable.runtimeType}<-")}
<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-<-""";
    CoreLogger.log(responseLog);
  }

  void logErrorResponseInfo({required int? statusCode, required Object error, required String requestUrl}) {
    final errorResponseLog = '''
REQUEST ERROR
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Status Code: $statusCode
Request Url: $requestUrl
Error String: $error
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX''';
    CoreLogger.log(errorResponseLog, color: LogColors.red);
  }
}
