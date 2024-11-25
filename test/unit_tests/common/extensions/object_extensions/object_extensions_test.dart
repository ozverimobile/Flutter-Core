import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Is Null', () {
    test('Test is null', () {
      Null nullObject;
      expect(nullObject.isNull, true);
    });

    test('Test is not null', () {
      const notNullObject = 'not null';
      expect(notNullObject.isNull, false);
    });
  });
}
