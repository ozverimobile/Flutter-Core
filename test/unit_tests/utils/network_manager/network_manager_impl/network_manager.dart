import 'package:flutter/foundation.dart';
import 'package:flutter_core/flutter_core.dart';

import '../network_manager_intercaptors.dart';
import 'base_response.dart';
import 'message.dart';

typedef ValidateStatus = bool Function(int? statusCode);

final class NetworkManager extends CoreNetworkManager {
  NetworkManager()
      : super(
          baseOptions: BaseOptions(
            baseUrl: _baseUrl,
          ),
          interceptors: [
            NetworkManagerIntercaptors(),
          ],
          printLogRequestInfo: true,
        );

  static const _baseUrl = 'https://localhost:8080';

  @override
  Future<BaseResponse<T>> request<T, M extends BaseModel<dynamic>>({
    required BaseRequestPath path,
    required RequestType type,
    required M responseEntityModel,
    bool hasBaseResponse = true,
    BaseModel<dynamic>? data,
    FormData? dioFormData,
    BaseModel<dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? pathSuffix,
    String? contentType,
    ResponseType? responseType,
    CancelToken? cancelToken,
    ValidateStatus? validateStatus,
    Duration connectionTimeout = const Duration(seconds: 25),
    Duration receiveTimeout = const Duration(seconds: 25),
    Duration sendTimeout = const Duration(seconds: 25),
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
  }) async {
    return await super.request<T, M>(
      path: path,
      type: type,
      responseEntityModel: responseEntityModel,
      hasBaseResponse: hasBaseResponse,
      data: data,
      dioFormData: dioFormData,
      queryParameters: queryParameters,
      headers: headers,
      pathSuffix: pathSuffix,
      contentType: contentType,
      responseType: responseType,
      cancelToken: cancelToken,
      validateStatus: validateStatus,
      connectionTimeout: connectionTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    ) as BaseResponse<T>;
  }

  @override
  Future<BaseResponse<T>> primitiveRequest<T>({
    required BaseRequestPath path,
    required RequestType type,
    BaseModel<dynamic>? data,
    FormData? dioFormData,
    BaseModel<dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? pathSuffix,
    String? contentType,
    ResponseType? responseType,
    CancelToken? cancelToken,
    ValidateStatus? validateStatus,
    Duration connectionTimeout = const Duration(seconds: 25),
    Duration receiveTimeout = const Duration(seconds: 25),
    Duration sendTimeout = const Duration(seconds: 25),
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
  }) async {
    return await super.primitiveRequest<T>(
      path: path,
      type: type,
      data: data,
      dioFormData: dioFormData,
      queryParameters: queryParameters,
      headers: headers,
      pathSuffix: pathSuffix,
      contentType: contentType,
      responseType: responseType,
      cancelToken: cancelToken,
      validateStatus: validateStatus,
      connectionTimeout: connectionTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    ) as BaseResponse<T>;
  }

  @override
  Map<String, dynamic> generateHeaders({required BaseRequestPath path}) {
    return {};
  }

  @override
  void onUnauthorized(DioException error) {
    if (kDebugMode) print('onUnauthorized');
  }

  @override
  void onServiceUnavailable(DioException error) {
    if (kDebugMode) print('onServiceUnavailable');
  }

  @override
  BaseResponse<T> getSuccessPrimitiveResponse<T>({required Response<T> response}) => BaseResponse(data: response.data, succeeded: true, statusCode: response.statusCode);

  @override
  BaseResponse<T> getSuccessResponse<T, M extends BaseModel<dynamic>>({required Response<Map<String, dynamic>> response, required M responseEntityModel, required bool hasBaseResponse}) {
    late dynamic json;
    if (hasBaseResponse) {
      json = response.data?['data'];
    } else {
      json = response.data;
    }

    T? data;

    if (json is List<dynamic>) {
      data = json.map((e) => responseEntityModel.fromJson(e as Map<String, dynamic>)).toList().cast<M>() as T;
    } else if (json is Map<String, dynamic>) {
      data = responseEntityModel.fromJson(json) as T;
    } else {
      data = json as T;
    }

    final succeeded = response.data?['succeeded'] as bool?;
    final messagesList = response.data?['messages'] as List?;
    List<Message>? messages;
    if (messagesList.isNotNullAndNotEmpty) {
      messages = messagesList!.cast<Map<String, dynamic>>().map((e) => Message(type: MessageType.fromString(e['type'] as String?), content: e['content'] as String?)).toList();
    }
    final statusCode = response.statusCode;

    return BaseResponse<T>(data: data, succeeded: succeeded, messages: messages, statusCode: statusCode);
  }

  @override
  BaseResponse<T> getErrorResponse<T>({required Object error}) {
    final statusCode = error is DioException ? error.response?.statusCode : null;
    List<dynamic>? messagesList;
    if (error is DioException && error.response?.data is Map<String, dynamic>) {
      messagesList = (error.response?.data as Map<String, dynamic>)['messages'] as List?;
    }
    final messages = messagesList?.cast<Map<String, dynamic>>().map((e) => Message(type: MessageType.fromString(e['type'] as String?), content: e['content'] as String?)).toList();

    return BaseResponse<T>(statusCode: statusCode, error: error, messages: messages);
  }
}
