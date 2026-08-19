import 'package:flutter_core/flutter_core.dart';
import 'package:material_ui/material_ui.dart';

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
