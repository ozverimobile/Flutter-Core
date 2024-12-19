import 'dart:async';

import 'package:flutter_core/flutter_core.dart';

/// [Future] EXTENSIONS
extension FutureExtensions<T> on Future<T> {
  /// Show loading until finished this method
  Future<T> loading({bool closeKeyboard = false}) async {
    try {
      CoreBuilderController.showLoader();
      if (closeKeyboard) Core.closeKeyboard();
      return await this;
    } catch (e) {
      rethrow;
    } finally {
      CoreBuilderController.hideLoader();
    }
  }

  Future<T> loadingInButton(int hashCode) async {
    try {
      CoreBuilderController.showLoaderInButton(hashCode);
      Core.closeKeyboard();
      return await this;
    } catch (e) {
      rethrow;
    } finally {
      CoreBuilderController.hideLoaderInButton(hashCode);
    }
  }
}
