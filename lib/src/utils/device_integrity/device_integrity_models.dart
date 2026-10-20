import 'package:flutter/foundation.dart';

/// Tespit edilen tehdidin türü.
enum CoreIntegrityThreatType {
  /// Android'de root (Magisk, KernelSU, APatch, SuperSU...), iOS'ta jailbreak (rootful/rootless).
  rootOrJailbreak,

  /// Çalışan uygulamaya kod enjeksiyonu: Frida, Xposed/LSPosed, Substrate, ElleKit, libhooker,
  /// jailbreak gizleme tweak'leri.
  hooking,

  /// Android emülatörü, iOS simülatörü veya Mac'te çalışan iOS uygulaması.
  emulator,

  /// Uygulamaya bağlı debugger / ptrace, Android'de debuggable yapılmış release APK.
  debugger,

  /// Yalnızca Android: bootloader kilidi açık veya doğrulanmış önyükleme `green` değil.
  bootloaderUnlocked,

  /// Yalnızca Android: geliştirici seçenekleri açık.
  developerMode,

  /// Yalnızca Android: USB hata ayıklama (ADB) açık.
  adbEnabled,

  /// Native tarafın döndürdüğü, bu sürümde tanınmayan tür.
  unknown;

  static CoreIntegrityThreatType fromName(String? name) =>
      values.firstWhere((type) => type.name == name, orElse: () => unknown);
}

/// Tek bir tespit.
///
/// [code] tespit yöntemini (`su_binary`, `frida_port`, `jailbreak_file`...), [detail] ise
/// bulunan somut değeri (dosya yolu, paket adı, property...) içerir. Loglama ve
/// sunucuya raporlama için uygundur.
@immutable
class CoreIntegrityFinding {
  const CoreIntegrityFinding({required this.type, required this.code, required this.detail});

  factory CoreIntegrityFinding.fromMap(Map<Object?, Object?> map) => CoreIntegrityFinding(
    type: CoreIntegrityThreatType.fromName(map['type'] as String?),
    code: map['code'] as String? ?? '',
    detail: map['detail'] as String? ?? '',
  );

  final CoreIntegrityThreatType type;
  final String code;
  final String detail;

  Map<String, String> toMap() => {'type': type.name, 'code': code, 'detail': detail};

  @override
  bool operator ==(Object other) =>
      other is CoreIntegrityFinding && other.type == type && other.code == code && other.detail == detail;

  @override
  int get hashCode => Object.hash(type, code, detail);

  @override
  String toString() => 'CoreIntegrityFinding(${type.name}, $code, $detail)';
}

/// `CoreDeviceIntegrity.check` sonucu.
@immutable
class CoreDeviceIntegrityResult {
  const CoreDeviceIntegrityResult({required this.findings, this.error});

  /// Kontrol yapılamadığında (desteklenmeyen platform hariç) döner. [error] doluysa
  /// native taraf hata vermiştir; bu durum da manipülasyon belirtisi olabilir.
  const CoreDeviceIntegrityResult.failed(Object this.error) : findings = const [];

  static const empty = CoreDeviceIntegrityResult(findings: []);

  final List<CoreIntegrityFinding> findings;

  /// Native kontrol çalıştırılamadıysa hata. Sıkı güvenlik isteyen uygulamalar
  /// [isCheckFailed] durumunu da tehdit olarak değerlendirmelidir.
  final Object? error;

  bool get isCheckFailed => error != null;

  bool get isRootedOrJailbroken => has(CoreIntegrityThreatType.rootOrJailbreak);
  bool get isHooked => has(CoreIntegrityThreatType.hooking);
  bool get isEmulator => has(CoreIntegrityThreatType.emulator);
  bool get isDebuggerAttached => has(CoreIntegrityThreatType.debugger);
  bool get isBootloaderUnlocked => has(CoreIntegrityThreatType.bootloaderUnlocked);
  bool get isDeveloperModeEnabled => has(CoreIntegrityThreatType.developerMode);
  bool get isAdbEnabled => has(CoreIntegrityThreatType.adbEnabled);

  /// Cihaz root/jailbreak'li veya uygulamaya hook enjekte edilmiş.
  ///
  /// Emülatör, debugger, bootloader ve geliştirici ayarları burada sayılmaz; bunlar
  /// geliştirme sırasında normaldir. Daha sıkı bir politika için [hasAny] kullanılır.
  bool get isCompromised => isRootedOrJailbroken || isHooked;

  /// Tespit edilen tehdit türleri.
  Set<CoreIntegrityThreatType> get threats => {for (final finding in findings) finding.type};

  bool has(CoreIntegrityThreatType type) => findings.any((finding) => finding.type == type);

  bool hasAny(Iterable<CoreIntegrityThreatType> types) => types.any(has);

  /// Belirli bir türe ait bulgular.
  List<CoreIntegrityFinding> findingsOf(CoreIntegrityThreatType type) =>
      findings.where((finding) => finding.type == type).toList();

  @override
  String toString() => 'CoreDeviceIntegrityResult(threats: ${threats.map((t) => t.name).toList()}, '
      'findings: ${findings.length}${error == null ? '' : ', error: $error'})';
}
