import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Decode JWT', () {
    final jwtDecoder = CoreJwtDecoder.instance;
    test('Test empty token', () {
      const token = '';

      expect(() => jwtDecoder.decodeJWT(token), throwsArgumentError);
    });

    test('Test invalid token', () {
      const token = 'invalid.token';

      expect(() => jwtDecoder.decodeJWT(token), throwsArgumentError);
    });

    test('Test valid token', () {
      const validToken = 'header.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.signature';
      final expectedPayload = {
        'alg': 'HS256',
        'typ': 'JWT',
      };
      final decoded = jwtDecoder.decodeJWT(validToken);
      expect(decoded, expectedPayload);
    });

    test('Test invalid payload (non-map)', () {
      const token = 'header.e30.signature';
      expect(() => jwtDecoder.decodeJWT(token), throwsArgumentError);
    });
  });
}
