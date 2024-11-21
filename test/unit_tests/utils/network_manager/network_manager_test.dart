import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models/product.dart';
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

    test('hasBaseResponse kontrolü yapılıyor.', () {});

    test('data kontrolü yapılıyor', () {});

    test('dioFormData kontrolü yapılıyor', () {});

    test('queryParameters kontrolü yapılıyor', () {});

    test('headers kontrolü yapılıyor', () {});

    test('pathSuffix kontrolü yapılıyor', () {});

    test('onUnauthorized kontrol ediliyor', () {});

    test('onServiceUnavailable', () {});

    test("Response'un List olma durumu kontrol ediliypr.", () {});

    test("Response'un Object olma durumu kontrol ediliyor.", () {});

    test("Response'un Primitive Type olma durumu kontrol ediliyor.", () {});

    test('İstek sırasında hata olma durumu kontrol ediliyor', () {});

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
  });

  test('data kontrolü yapılıyor (primitiveRequest).', () {});

  test('dioFormData kontrolü yapılıyor (primitiveRequest).', () {});

  test('queryParameters kontrolü yapılıyor (primitiveRequest).', () {});

  test('headers kontrolü yapılıyor (primitiveRequest).', () {});

  test('pathSuffix kontrolü yapılıyor (primitiveRequest).', () {});

  test('onUnauthorized kontrol ediliyor (primitiveRequest).', () {});

  test('onServiceUnavailable (primitiveRequest).', () {});

  test("Response'un Uint8List olma durumu kontrol ediliyor (primitiveRequest).", () {});

  test("Response'un Primitive Type olma durumu kontrol ediliyor (primitiveRequest).", () {});

  test('İstek sırasında hata olma durumu kontrol ediliyor (primitiveRequest).', () {});
}
