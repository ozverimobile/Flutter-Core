import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

abstract class CoreBuilderController {
  static final isShowLoadingNotifier = ValueNotifier<bool>(false);
  static final isShowLoadingInButtonNotifier = ValueNotifier<List<int>>([]);

  static void showLoader() {
    assert(CoreBuilder.usesCoreBuilder, 'Core.showLoader() can only be used with CoreBuilder');
    isShowLoadingNotifier.value = true;
  }

  static void hideLoader() {
    assert(CoreBuilder.usesCoreBuilder, 'Core.hideLoader() can only be used with CoreBuilder');
    isShowLoadingNotifier.value = false;
  }

  static void showLoaderInButton(int hashCode) {
    assert(CoreBuilder.usesCoreBuilder, 'Core.showLoader() can only be used with CoreBuilder');
    isShowLoadingInButtonNotifier.value = [...isShowLoadingInButtonNotifier.value, hashCode];
  }

  static void hideLoaderInButton(int hashCode) {
    assert(CoreBuilder.usesCoreBuilder, 'Core.hideLoader() can only be used with CoreBuilder');
    final buttons = isShowLoadingInButtonNotifier.value..remove(hashCode);
    isShowLoadingInButtonNotifier.value = [...buttons];
  }
}
