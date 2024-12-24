import 'dart:async';

import 'package:meta/meta.dart';

mixin IRetriable {
  Future<void> execute();
}

abstract class Retriable<T> implements IRetriable {
  Retriable({
    this.maxRetries = 3,
    this.delayMultiplier = Duration.zero,
  });

  final int maxRetries;
  final Duration delayMultiplier;

  late T _data;
  bool _isSuccess = false;
  int _currentRetry = 0;

  bool get isSuccess => _isSuccess;

  @protected
  FutureOr<T> retryCallback();
  @protected
  void onRetry(Object error, int currentRetry) {}

  @override
  @nonVirtual
  Future<T> execute() async {
    try {
      if (_isSuccess) return _data;
      _data = await retryCallback();
      _isSuccess = true;
      return _data;
    } catch (ex) {
      if (_currentRetry < maxRetries) {
        _currentRetry = _currentRetry + 1;
        await Future<void>.delayed(Duration(milliseconds: delayMultiplier.inMilliseconds * _currentRetry));
        onRetry(ex, _currentRetry);
        return execute();
      } else {
        rethrow;
      }
    }
  }
}
