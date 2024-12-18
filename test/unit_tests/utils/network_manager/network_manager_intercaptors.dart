import 'dart:typed_data';

import 'package:flutter_core/flutter_core.dart';

import 'network_manager_impl/request_path.dart';

class NetworkManagerIntercaptors extends InterceptorsWrapper with NetworkManagerIntercaptorsMixin {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path == RequestPath.defaultRequestTest.value) {
      defaultRequestTest(options, handler);
    } else if (options.path == RequestPath.defaultPrimitiveRequestTest.value) {
      defaultPrimitiveRequestTest(options, handler);
    } else if (options.path == RequestPath.hasBaseResponseControlTest.value) {
      hasBaseResponseControlTest(options, handler);
    } else if (options.path == RequestPath.dataControlTest.value) {
      dataControlTest(options, handler);
    } else if (options.path == RequestPath.dioFormDataControlTest.value) {
      dioFormDataControlTest(options, handler);
    } else if (options.path == RequestPath.queryParametersControlTest.value) {
      queryParametersControlTest(options, handler);
    } else if (options.path == RequestPath.headersControlTest.value) {
      headersControlTest(options, handler);
    } else if (options.path == '${RequestPath.pathSuffixControlTest.value}/path-suffix-test') {
      pathSuffixControlTest(options, handler);
    } else if (options.path == RequestPath.onUnauthorizedRequestTest.value) {
      onUnauthorizedRequestTest(options, handler);
    } else if (options.path == RequestPath.onServiceUnavailableRequestTest.value) {
      onServiceUnavailableRequestTest(options, handler);
    } else if (options.path == RequestPath.generalErrorRequestTest.value) {
      generalErrorRequestTest(options, handler);
    } else if (options.path == RequestPath.listResponseControlTest.value) {
      listResponseControlTest(options, handler);
    } else if (options.path == RequestPath.objectResponseControlTest.value) {
      objectResponseControlTest(options, handler);
    } else if (options.path == RequestPath.primitiveResponseControlTest.value) {
      primitiveResponseControlTest(options, handler);
    } else if (options.path == RequestPath.dataControlTestForPrimitiveRequest.value) {
      dataControlTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.dioFormDataControlTestForPrimitiveRequest.value) {
      dioFormDataControlTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.queryParametersControlTestForPrimitiveRequest.value) {
      queryParametersControlTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.headersControlTestForPrimitiveRequest.value) {
      headersControlTestForPrimitiveRequest(options, handler);
    } else if (options.path == '${RequestPath.pathSuffixControlTestForPrimitiveRequest.value}/path-suffix-test') {
      pathSuffixControlTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.onUnauthorizedRequestTestForPrimitiveRequest.value) {
      onUnauthorizedRequestTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.onServiceUnavailableRequestTestForPrimitiveRequest.value) {
      onServiceUnavailableRequestTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.generalErrorRequestTestForPrimitiveRequest.value) {
      generalErrorRequestTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.uint8ListControlTestForPrimitiveRequest.value) {
      uint8ListControlTestForPrimitiveRequest(options, handler);
    } else if (options.path == RequestPath.primitiveTypeControlTestForPrimitiveRequest.value) {
      primitiveTypeControlTestForPrimitiveRequest(options, handler);
    } else {
      handler.next(options);
    }
  }
}

mixin NetworkManagerIntercaptorsMixin {
  void defaultRequestTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'data': {
        'id': 1,
        'name': 'test',
      },
      'succeeded': true,
      'messages': <dynamic>[],
    };
    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void defaultPrimitiveRequestTest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        data: 'Primitive data',
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void hasBaseResponseControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'id': 1,
      'name': 'test',
      'succeeded': true,
      'messages': [
        {
          'type': 'success',
          'content': 'Success',
        },
      ],
    };
    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void dataControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'data': options.data,
      'succeeded': true,
      'messages': <dynamic>[],
    };
    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void dioFormDataControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final formData = options.data as FormData;
    final id = int.parse(formData.fields.first.value);
    final name = formData.fields.last.value;
    final map = <String, dynamic>{
      'data': {
        'id': id,
        'name': name,
      },
      'succeeded': true,
      'messages': <dynamic>[],
    };
    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void queryParametersControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'data': options.queryParameters,
      'succeeded': true,
      'messages': <dynamic>[],
    };
    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void headersControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'data': options.headers,
      'succeeded': true,
      'messages': <dynamic>[],
    };
    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void pathSuffixControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final pathSuffix = options.path.split('/').last;
    final map = <String, dynamic>{
      'data': pathSuffix,
      'succeeded': true,
      'messages': <dynamic>[],
    };
    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void onUnauthorizedRequestTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'succeeded': false,
      'messages': [
        {
          'type': 'error',
          'content': 'Bad Response',
        },
      ],
    };

    handler.reject(
      DioException.badResponse(
        statusCode: 401,
        requestOptions: options,
        response: Response(
          data: map,
          requestOptions: options,
          statusCode: 401,
          statusMessage: 'Bad Response',
        ),
      ),
    );
  }

  void onServiceUnavailableRequestTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'succeeded': false,
      'messages': [
        {
          'type': 'info',
          'content': 'Service Unavailable',
        },
      ],
    };
    handler.reject(
      DioException.badResponse(
        statusCode: 503,
        requestOptions: options,
        response: Response(
          data: map,
          requestOptions: options,
          statusCode: 503,
          statusMessage: 'Service Unavailable',
        ),
      ),
    );
  }

  void generalErrorRequestTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'succeeded': false,
      'messages': [
        {
          'type': 'error',
          'content': 'Not Found',
        },
      ],
    };
    handler.reject(
      DioException.badResponse(
        statusCode: 404,
        requestOptions: options,
        response: Response(
          data: map,
          requestOptions: options,
          statusCode: 404,
          statusMessage: 'Not Found',
        ),
      ),
    );
  }

  void listResponseControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'data': [
        {
          'id': 1,
          'name': 'test',
        }
      ],
      'succeeded': true,
      'messages': <dynamic>[],
    };

    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void objectResponseControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'data': {
        'id': 1,
        'name': 'test',
      },
      'succeeded': true,
      'messages': <dynamic>[],
    };

    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void primitiveResponseControlTest(RequestOptions options, RequestInterceptorHandler handler) {
    final map = <String, dynamic>{
      'data': 1,
      'succeeded': true,
      'messages': <dynamic>[],
    };

    handler.resolve(
      Response(
        data: map,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void dataControlTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data as Map<String, dynamic>;
    handler.resolve(
      Response(
        data: data['name'],
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void dioFormDataControlTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final formData = options.data as FormData;
    final name = formData.fields.last.value;
    handler.resolve(
      Response(
        data: name,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void queryParametersControlTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        data: options.queryParameters['name'],
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void headersControlTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        data: options.headers['name'],
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void pathSuffixControlTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final pathSuffix = options.path.split('/').last;
    handler.resolve(
      Response(
        data: pathSuffix,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void onUnauthorizedRequestTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(
      DioException.badResponse(
        statusCode: 401,
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          statusMessage: 'Bad Response',
        ),
      ),
    );
  }

  void onServiceUnavailableRequestTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(
      DioException.badResponse(
        statusCode: 503,
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 503,
          statusMessage: 'Service Unavailable',
        ),
      ),
    );
  }

  void generalErrorRequestTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(
      DioException.badResponse(
        statusCode: 404,
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          statusMessage: 'Not Found',
        ),
      ),
    );
  }

  void uint8ListControlTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = Uint8List.fromList(List.generate(10, (i) => i));
    handler.resolve(
      Response(
        data: data,
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }

  void primitiveTypeControlTestForPrimitiveRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        data: 'test',
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
      ),
    );
  }
}
