import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('List Extension Test', () {
    List<dynamic>? nullList;
    expect(nullList.isNullOrEmpty, true);

    expect(<dynamic>[].isNullOrEmpty, true);

    expect(<dynamic>[1, 2, 3].isNullOrEmpty, false);

    expect(nullList.isNotNullAndNotEmpty, false);

    expect(<dynamic>[].isNotNullAndNotEmpty, false);

    expect(<dynamic>[1, 2, 3].isNotNullAndNotEmpty, true);

    expect(nullList.notContains(1), true);

    expect(<dynamic>[1, 2, 3].notContains(1), false);

    expect(<dynamic>[1, 2, 3].notContains(4), true);

    expect(nullList.multiply(times: 2).length, 0);

    expect(() => <dynamic>[].multiply(times: 2), throwsException);

    expect(<dynamic>[1, 2, 3].multiply(times: 3).length, 3);

    expect(<dynamic>[1, 2, 3].multiply(times: 2).length, 2);

    expect(<dynamic>[1, 2, 3].multiply(times: 4).length, 4);
  });
}
