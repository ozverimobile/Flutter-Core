/// A core library for Flutter Mobile Apps.
library;

export 'package:collection/collection.dart';
export 'package:dio/dio.dart' show BaseOptions, CancelToken, Dio, DioException, DioExceptionType, ErrorInterceptorHandler, FormData, Headers, InterceptorsWrapper, MultipartFile, Options, RequestInterceptorHandler, RequestOptions, Response, ResponseInterceptorHandler, ResponseType;
export 'package:firebase_remote_config/firebase_remote_config.dart';
export 'package:sqflite/sqflite.dart' show Database;

export 'src/common/common.dart';
export 'src/core/core.dart';
export 'src/utils/utils.dart' hide CorePlatformChannel;
export 'src/widgets/widgets.dart';
