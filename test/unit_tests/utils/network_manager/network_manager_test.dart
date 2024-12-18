import 'dart:typed_data';

import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models/product.dart';
import 'network_manager_impl/message.dart';
import 'network_manager_impl/network_manager.dart';
import 'network_manager_impl/request_path.dart';

void main() {
  group('Network Manager', () {
    test(
      'Basit bir istek atılıyor.',
      () async {
        final networkManager = NetworkManager();
        final response = await networkManager.request<Product, Product>(path: RequestPath.defaultRequestTest, type: RequestType.get, responseEntityModel: const Product());
        expect(response.succeeded, true);
        expect(response.data, isA<Product>());
        expect(response.data!.id, 1);
        expect(response.data!.name, 'test');
        expect(response.statusCode, 200);
        expect(response.messages, isNull);
        expect(response.error, isNull);
      },
    );

    test('hasBaseResponse kontrolü yapılıyor.', () async {
      final networkManager = NetworkManager();
      final response = await networkManager.request<Product, Product>(path: RequestPath.hasBaseResponseControlTest, type: RequestType.get, hasBaseResponse: false, responseEntityModel: const Product());
      expect(response.succeeded, true);
      expect(response.data, isA<Product>());
      expect(response.data!.id, 1);
      expect(response.data!.name, 'test');
      expect(response.statusCode, 200);
      expect(response.messages?.length, 1);
      expect(response.messages?[0].type, MessageType.success);
      expect(response.messages?[0].content, 'Success');
      expect(response.messages, isA<List<Message>>());
      expect(response.error, isNull);
    });

    test('data kontrolü yapılıyor', () async {
      final networkManager = NetworkManager();
      const data = Product(id: 1, name: 'test');
      final response = await networkManager.request<Product, Product>(path: RequestPath.dataControlTest, type: RequestType.post, data: data, responseEntityModel: const Product());
      expect(response.succeeded, true);
      expect(response.data, isA<Product>());
      expect(response.data!.id, data.id);
      expect(response.data!.name, data.name);
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('dioFormData kontrolü yapılıyor', () async {
      final networkManager = NetworkManager();
      final formData = FormData.fromMap(const Product(id: 1, name: 'test').toJson());
      final response = await networkManager.request<Product, Product>(path: RequestPath.dioFormDataControlTest, type: RequestType.post, dioFormData: formData, responseEntityModel: const Product());
      expect(response.succeeded, true);
      expect(response.data, isA<Product>());
      expect(response.data!.id, 1);
      expect(response.data!.name, 'test');
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('queryParameters kontrolü yapılıyor', () async {
      final networkManager = NetworkManager();
      const queryParameters = Product(id: 1, name: 'test');
      final response = await networkManager.request<Product, Product>(path: RequestPath.queryParametersControlTest, type: RequestType.post, queryParameters: queryParameters, responseEntityModel: const Product());
      expect(response.succeeded, true);
      expect(response.data, isA<Product>());
      expect(response.data!.id, queryParameters.id);
      expect(response.data!.name, queryParameters.name);
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('headers kontrolü yapılıyor', () async {
      final headers = <String, dynamic>{
        'id': 1,
        'name': 'test',
      };

      final networkManager = NetworkManager();
      final response = await networkManager.request<Product, Product>(path: RequestPath.headersControlTest, type: RequestType.get, headers: headers, responseEntityModel: const Product());
      expect(response.succeeded, true);
      expect(response.data, isA<Product>());
      expect(response.data!.id, 1);
      expect(response.data!.name, 'test');
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('pathSuffix kontrolü yapılıyor', () async {
      final networkManager = NetworkManager();
      const pathSuffix = 'path-suffix-test';
      final response = await networkManager.request<String, EmptyObject>(path: RequestPath.pathSuffixControlTest, type: RequestType.get, pathSuffix: '/$pathSuffix', responseEntityModel: const EmptyObject());
      expect(response.succeeded, true);
      expect(response.data, pathSuffix);
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('onUnauthorized kontrol ediliyor', () async {
      final networkManager = NetworkManager();
      final response = await networkManager.request<EmptyObject, EmptyObject>(path: RequestPath.onUnauthorizedRequestTest, type: RequestType.get, responseEntityModel: const EmptyObject());
      expect(response.statusCode, 401);
      expect(response.messages?.first.type, MessageType.error);
      expect(response.messages?.first.content, 'Bad Response');
      final dioException = response.error! as DioException;
      expect(dioException.response?.statusCode, 401);
      expect(dioException.response?.statusMessage, 'Bad Response');
    });

    test('onServiceUnavailable', () async {
      final networkManager = NetworkManager();
      final response = await networkManager.request<EmptyObject, EmptyObject>(path: RequestPath.onServiceUnavailableRequestTest, type: RequestType.get, responseEntityModel: const EmptyObject());
      expect(response.statusCode, 503);
      expect(response.messages?.first.type, MessageType.info);
      expect(response.messages?.first.content, 'Service Unavailable');
      final dioException = response.error! as DioException;
      expect(dioException.response?.statusCode, 503);
      expect(dioException.response?.statusMessage, 'Service Unavailable');
    });

    test('İstek sırasında hata olma durumu kontrol ediliyor', () async {
      final networkManager = NetworkManager();
      final response = await networkManager.request<EmptyObject, EmptyObject>(path: RequestPath.generalErrorRequestTest, type: RequestType.get, responseEntityModel: const EmptyObject());
      expect(response.statusCode, 404);
      expect(response.messages?.first.type, MessageType.error);
      expect(response.messages?.first.content, 'Not Found');
      final dioException = response.error! as DioException;
      expect(dioException.response?.statusCode, 404);
      expect(dioException.response?.statusMessage, 'Not Found');
    });

    test("Response'un List olma durumu kontrol ediliyor.", () async {
      final networkManager = NetworkManager();
      final response = await networkManager.request<List<Product>, Product>(path: RequestPath.listResponseControlTest, type: RequestType.get, responseEntityModel: const Product());
      expect(response.succeeded, true);
      expect(response.data, isA<List<Product>>());
      expect(response.data?.length, 1);
      expect(response.data!.first.id, 1);
      expect(response.data!.first.name, 'test');
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test("Response'un Object olma durumu kontrol ediliyor.", () async {
      final networkManager = NetworkManager();
      final response = await networkManager.request<Product, Product>(path: RequestPath.objectResponseControlTest, type: RequestType.get, responseEntityModel: const Product());
      expect(response.succeeded, true);
      expect(response.data, isA<Product>());
      expect(response.data!.id, 1);
      expect(response.data!.name, 'test');
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test("Response'un Primitive Type olma durumu kontrol ediliyor.", () async {
      final networkManager = NetworkManager();
      final response = await networkManager.request<int, EmptyObject>(path: RequestPath.primitiveResponseControlTest, type: RequestType.get, responseEntityModel: const EmptyObject());
      expect(response.succeeded, true);
      expect(response.data, isA<int>());
      expect(response.data, 1);
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test(
      'Basit bir istek atılıyor (primitiveRequest).',
      () async {
        final networkManager = NetworkManager();
        final response = await networkManager.primitiveRequest<String>(path: RequestPath.defaultPrimitiveRequestTest, type: RequestType.get);
        expect(response.succeeded, true);
        expect(response.data, 'Primitive data');
        expect(response.statusCode, 200);
        expect(response.messages, isNull);
        expect(response.error, isNull);
      },
    );

    test('data kontrolü yapılıyor (primitiveRequest).', () async {
      final networkManager = NetworkManager();
      const data = Product(id: 1, name: 'test');
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.dataControlTestForPrimitiveRequest, type: RequestType.post, data: data);
      expect(response.succeeded, true);
      expect(response.data, isA<String>());
      expect(response.data, data.name);
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('dioFormData kontrolü yapılıyor (primitiveRequest).', () async {
      final networkManager = NetworkManager();
      final formData = FormData.fromMap(const Product(id: 1, name: 'test').toJson());
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.dioFormDataControlTestForPrimitiveRequest, type: RequestType.post, dioFormData: formData);
      expect(response.succeeded, true);
      expect(response.data, isA<String>());
      expect(response.data, 'test');
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('queryParameters kontrolü yapılıyor (primitiveRequest).', () async {
      final networkManager = NetworkManager();
      const queryParameters = Product(id: 1, name: 'test');
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.queryParametersControlTestForPrimitiveRequest, type: RequestType.post, queryParameters: queryParameters);
      expect(response.succeeded, true);
      expect(response.data, isA<String>());
      expect(response.data, queryParameters.name);
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('headers kontrolü yapılıyor (primitiveRequest).', () async {
      final headers = <String, dynamic>{
        'id': 1,
        'name': 'test',
      };

      final networkManager = NetworkManager();
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.headersControlTestForPrimitiveRequest, type: RequestType.get, headers: headers);
      expect(response.succeeded, true);
      expect(response.data, isA<String>());
      expect(response.data, 'test');
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('pathSuffix kontrolü yapılıyor (primitiveRequest).', () async {
      final networkManager = NetworkManager();
      const pathSuffix = 'path-suffix-test';
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.pathSuffixControlTestForPrimitiveRequest, type: RequestType.get, pathSuffix: '/$pathSuffix');
      expect(response.succeeded, true);
      expect(response.data, pathSuffix);
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test('onUnauthorized kontrol ediliyor (primitiveRequest).', () async {
      final networkManager = NetworkManager();
      final response = await networkManager.primitiveRequest<dynamic>(path: RequestPath.onUnauthorizedRequestTestForPrimitiveRequest, type: RequestType.get);
      expect(response.statusCode, 401);
      final dioException = response.error! as DioException;
      expect(dioException.response?.statusCode, 401);
      expect(dioException.response?.statusMessage, 'Bad Response');
    });

    test('onServiceUnavailable (primitiveRequest).', () async {
      final networkManager = NetworkManager();
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.onServiceUnavailableRequestTestForPrimitiveRequest, type: RequestType.get);
      expect(response.statusCode, 503);
      final dioException = response.error! as DioException;
      expect(dioException.response?.statusCode, 503);
      expect(dioException.response?.statusMessage, 'Service Unavailable');
    });

    test('İstek sırasında hata olma durumu kontrol ediliyor (primitiveRequest).', () async {
      final networkManager = NetworkManager();
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.generalErrorRequestTestForPrimitiveRequest, type: RequestType.get);
      expect(response.statusCode, 404);
      final dioException = response.error! as DioException;
      expect(dioException.response?.statusCode, 404);
      expect(dioException.response?.statusMessage, 'Not Found');
    });

    test("Response'un Uint8List olma durumu kontrol ediliyor (primitiveRequest).", () async {
      final networkManager = NetworkManager();
      final response = await networkManager.primitiveRequest<Uint8List>(path: RequestPath.uint8ListControlTestForPrimitiveRequest, type: RequestType.get);
      expect(response.succeeded, true);
      expect(response.data, isA<Uint8List>());
      expect(response.data, Uint8List.fromList(List.generate(10, (i) => i)));
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });

    test("Response'un Primitive Type olma durumu kontrol ediliyor (primitiveRequest).", () async {
      final networkManager = NetworkManager();
      final response = await networkManager.primitiveRequest<String>(path: RequestPath.primitiveTypeControlTestForPrimitiveRequest, type: RequestType.get);
      expect(response.succeeded, true);
      expect(response.data, isA<String>());
      expect(response.data, 'test');
      expect(response.statusCode, 200);
      expect(response.messages, isNull);
      expect(response.error, isNull);
    });
  });
}
