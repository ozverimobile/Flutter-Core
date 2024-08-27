import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

abstract class CoreBuilderController {
  static final isShowLoadingNotifier = ValueNotifier<bool>(false);

  static void showLoader() {
    assert(CoreBuilder.usesCoreBuilder, 'Core.showLoader() can only be used with CoreBuilder');
    isShowLoadingNotifier.value = true;
  }

  static void hideLoader() {
    assert(CoreBuilder.usesCoreBuilder, 'Core.hideLoader() can only be used with CoreBuilder');
    isShowLoadingNotifier.value = false;
  }
}
