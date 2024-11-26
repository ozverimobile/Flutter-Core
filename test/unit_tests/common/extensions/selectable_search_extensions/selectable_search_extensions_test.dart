import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test List String to List Selectable Sheet', () {
    test('Test Convert to Selectable Search List', () {
      final list = <String?>['a', 'b', 'c', null];
      final result = list.toSelectableSearchList();
      expect(result.length, 3);
      expect(result[0].title, 'a');
      expect(result[1].title, 'b');
      expect(result[2].title, 'c');
      expect(result.length, list.length - 1);
    });
  });

  group('Test List Num to List Selectable Sheet', () {
    test('Test Convert to Selectable Search List', () {
      final list = <num?>[1, 2, 3, null];
      final result = list.toSelectableSearchList();
      expect(result.length, 3);
      expect(result[0].title, '1');
      expect(result[1].title, '2');
      expect(result[2].title, '3');
      expect(result.length, list.length - 1);
    });
  });
}
