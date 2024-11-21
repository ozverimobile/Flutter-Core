import 'package:flutter_core/flutter_core.dart';

import 'network_manager_impl/request_path.dart';

class NetworkManagerIntercaptors extends InterceptorsWrapper with NetworkManagerIntercaptorsMixin {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path.contains(RequestPath.defaultRequestTest.value) && options.method == 'GET') {
      defaultRequestTest(options, handler);
    } else if (options.path.contains(RequestPath.defaultPrimitiveRequestTest.value) && options.method == 'GET') {
      defaultPrimitiveRequestTest(options, handler);
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

  void defaultRequestHasBaseResponseTest(RequestOptions options, RequestInterceptorHandler handler) {
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
}
