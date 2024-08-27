import 'package:app_settings/app_settings.dart';
import 'package:flutter_core/src/utils/app_settings/protocol/protocol.dart';

abstract interface class ICoreOpenAppSettings {
  Future<void> openAppSettings({CoreAppSettingsType type = CoreAppSettingsType.settings, bool asAnotherTask = false});

  Future<void> openAppSettingsPanel({required CoreAppSettingsPanelType type});
}

class CoreOpenAppSettings implements ICoreOpenAppSettings {
  CoreOpenAppSettings._();

  static final instance = CoreOpenAppSettings._();

  @override
  Future<void> openAppSettings({CoreAppSettingsType type = CoreAppSettingsType.settings, bool asAnotherTask = false}) async {
    final settingsType = AppSettingsType.values[type.index];
    await AppSettings.openAppSettings(type: settingsType, asAnotherTask: asAnotherTask);
  }

  @override
  Future<void> openAppSettingsPanel({required CoreAppSettingsPanelType type}) async {
    final panelType = AppSettingsPanelType.values[type.index];
    await AppSettings.openAppSettingsPanel(panelType);
  }
}
