import 'package:flutter/physics.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Retriable Tests',
    () async {
      final intRetriable = _IntRetriable();
      final result = await intRetriable.execute();
      expect(result, 3);
      expect(intRetriable._executions, 4);
      expect(intRetriable.isSuccess, true);

      await intRetriable.execute();
      expect(intRetriable._executions, 4);

      final intRetriableWithDelay = _IntRetriable(delayMultiplier: const Duration(milliseconds: 100));
      final stopwatch = Stopwatch()..start();
      await intRetriableWithDelay.execute();
      stopwatch.stop();
      expect(nearEqual(600, stopwatch.elapsedMilliseconds.toDouble(), 25), true);

      final intRetriableWithMaxRetries = _IntRetriable(maxRetries: 2);
      expect(intRetriableWithMaxRetries.execute, throwsException);
      expect(intRetriableWithMaxRetries.isSuccess, false);
    },
  );
}

class _IntRetriable extends Retriable<int> {
  _IntRetriable({super.delayMultiplier, super.maxRetries});
  var _data = 0;
  var _executions = 0;

  @override
  int retryCallback() {
    _executions++;
    if (_data < 3) {
      _data++;
      throw Exception('Error');
    }
    return _data;
  }
}
