import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_core/src/utils/network_manager/error_messages.dart';

@immutable
final class CreatingErrorMessageFromDioException {
  CreatingErrorMessageFromDioException(DioException exception, {ErrorMessages errorMessages = const ErrorMessages(), this.includeDebugMessage = true}) {
    _exception = exception;
    _errorMessages = errorMessages;
  }

  late final DioException _exception;
  late final ErrorMessages _errorMessages;
  late final bool includeDebugMessage;

  String get message => '${_prepareMessage()}${_getDioMessage(_exception)}';

  String _prepareMessage() {
    if (_exception.type == DioExceptionType.connectionTimeout) return _errorMessages.connectionTimeout;
    if (_exception.type == DioExceptionType.sendTimeout) return _errorMessages.sendTimeout;
    if (_exception.type == DioExceptionType.receiveTimeout) return _errorMessages.receiveTimeout;
    if (_exception.type == DioExceptionType.badCertificate) return _errorMessages.badCertificate;
    if (_exception.type == DioExceptionType.badResponse) return _handleStatusCode(_exception);
    if (_exception.type == DioExceptionType.cancel) return _errorMessages.cancel;
    if (_exception.type == DioExceptionType.connectionError) return _handleExceptionType(_exception);

    return _errorMessages.somethingWentWrong;
  }

  String _getDioMessage(DioException exception) => (kDebugMode && includeDebugMessage) ? ' ---> ${exception.message}' : '';

  String _handleStatusCode(DioException exception) => _errorMessages.statusCodeMessages[exception.response?.statusCode] ?? _errorMessages.somethingWentWrong;

  String _handleExceptionType(DioException exception) => switch (exception.error) {
        SocketException _ => _errorMessages.socketException,
        HttpException _ => _errorMessages.httpException,
        HandshakeException _ => _errorMessages.handshakeException,
        CertificateException _ => _errorMessages.certificateException,
        _ => _errorMessages.somethingWentWrong,
      };
}
