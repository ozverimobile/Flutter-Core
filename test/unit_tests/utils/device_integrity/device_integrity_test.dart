import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_core/device_integrity');
  Object? Function() reply = () => <Object?>[];

  setUp(() {
    CoreDeviceIntegrity.debugIsSupported = true;
    reply = () => <Object?>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'check');
      return reply();
    });
  });

  tearDown(() {
    CoreDeviceIntegrity.debugIsSupported = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  Map<String, String> finding(String type, String code, String detail) => {'type': type, 'code': code, 'detail': detail};

  test('bulgu yoksa temiz sonuç', () async {
    final result = await CoreDeviceIntegrity.check();
    expect(result.findings, isEmpty);
    expect(result.isCompromised, isFalse);
    expect(result.isCheckFailed, isFalse);
    expect(await CoreDeviceIntegrity.isCompromised(), isFalse);
  });

  test('root ve hook bulguları isCompromised yapar', () async {
    reply = () => [
      finding('rootOrJailbreak', 'su_binary', '/system/xbin/su'),
      finding('hooking', 'frida_port', '127.0.0.1:27042'),
    ];
    final result = await CoreDeviceIntegrity.check();
    expect(result.isRootedOrJailbroken, isTrue);
    expect(result.isHooked, isTrue);
    expect(result.isCompromised, isTrue);
    expect(result.threats, {CoreIntegrityThreatType.rootOrJailbreak, CoreIntegrityThreatType.hooking});
    expect(result.findingsOf(CoreIntegrityThreatType.rootOrJailbreak).single.detail, '/system/xbin/su');
  });

  test('emülatör, debugger ve geliştirici ayarları isCompromised sayılmaz', () async {
    reply = () => [
      finding('emulator', 'emulator_file', '/dev/qemu_pipe'),
      finding('debugger', 'ptrace', 'TracerPid=123'),
      finding('bootloaderUnlocked', 'verified_boot', 'ro.boot.verifiedbootstate=orange'),
      finding('developerMode', 'developer_options', '1'),
      finding('adbEnabled', 'adb_enabled', '1'),
    ];
    final result = await CoreDeviceIntegrity.check();
    expect(result.isCompromised, isFalse);
    expect(result.isEmulator, isTrue);
    expect(result.isDebuggerAttached, isTrue);
    expect(result.isBootloaderUnlocked, isTrue);
    expect(result.isDeveloperModeEnabled, isTrue);
    expect(result.isAdbEnabled, isTrue);
    expect(result.hasAny([CoreIntegrityThreatType.emulator, CoreIntegrityThreatType.hooking]), isTrue);
  });

  test('tanınmayan tür unknown olur', () async {
    reply = () => [finding('newThreat', 'x', 'y')];
    final result = await CoreDeviceIntegrity.check();
    expect(result.findings.single.type, CoreIntegrityThreatType.unknown);
    expect(result.isCompromised, isFalse);
  });

  test('native hata fırlatmaz, isCheckFailed döner', () async {
    reply = () => throw PlatformException(code: 'INTEGRITY_CHECK_FAILED');
    final result = await CoreDeviceIntegrity.check();
    expect(result.isCheckFailed, isTrue);
    expect(result.isCompromised, isFalse);
    expect(await CoreDeviceIntegrity.isCompromised(), isFalse);
    expect(await CoreDeviceIntegrity.isCompromised(failClosed: true), isTrue);
  });

  test('desteklenmeyen platformda kanal çağrılmaz', () async {
    CoreDeviceIntegrity.debugIsSupported = false;
    reply = () => fail('kanal çağrılmamalı');
    final result = await CoreDeviceIntegrity.check();
    expect(result.findings, isEmpty);
    expect(result.isCheckFailed, isFalse);
  });
}
