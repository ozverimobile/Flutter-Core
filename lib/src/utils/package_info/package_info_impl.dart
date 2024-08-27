import 'package:package_info_plus/package_info_plus.dart';

abstract interface class ICorePackageInfo {
  Future<String?> get appName;

  Future<String?> get packageName;

  Future<String?> get version;

  Future<String?> get buildNumber;
}

class CorePackageInfo implements ICorePackageInfo{
  CorePackageInfo._();

  static final instance = CorePackageInfo._();
  final _packageInfo = PackageInfo.fromPlatform();

  @override
  Future<String?> get appName async {
    final info = await _packageInfo;
    return info.appName;
  }

  @override
  Future<String?> get buildNumber async {
    final info = await _packageInfo;
    return info.buildNumber;
  }

  @override
  Future<String?> get packageName async {
    final info = await _packageInfo;
    return info.packageName;
  }

  @override
  Future<String?> get version async {
    final info = await _packageInfo;
    return info.version;
  }
}
