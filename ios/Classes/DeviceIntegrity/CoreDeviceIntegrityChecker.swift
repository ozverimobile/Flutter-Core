import Darwin
import Foundation
import MachO
import UIKit

/// Jailbreak, hook (Frida/Substrate/ElleKit/libhooker), simülatör ve debugger tespiti.
///
/// Tek bir kontrol kolayca atlatılabildiği için birbirinden bağımsız birçok yöntem kullanılır:
/// farklı API'lerle dosya kontrolü (`FileManager`, `stat`, `access`, `fopen`), sembolik linkler,
/// sandbox dışına yazma, `fork`, yüklü dylib'ler, `DYLD_INSERT_LIBRARIES`, URL şemaları,
/// kök dosya sisteminin bağlanma şekli, Frida portu ve `P_TRACED` bayrağı.
///
/// Her bulgu `{type, code, detail}` sözlüğü olarak döner; kararı Dart tarafı verir.
/// Ana thread'den çağrılmamalıdır (URL şeması kontrolü için ana thread'e senkron geçer).
final class CoreDeviceIntegrityChecker {
  static let root = "rootOrJailbreak"
  static let hook = "hooking"
  static let emulator = "emulator"
  static let debugger = "debugger"

  private var findings: [[String: String]] = []

  func check() -> [[String: String]] {
    findings = []
    #if targetEnvironment(simulator)
      // Simülatör Mac'in dosya sistemini gördüğü için (/bin/bash vb.) jailbreak kontrolleri yanlış pozitif verir.
      add(Self.emulator, "simulator", "targetEnvironment(simulator)")
      checkDebugger()
    #else
      if #available(iOS 14.0, *), ProcessInfo.processInfo.isiOSAppOnMac {
        add(Self.emulator, "ios_app_on_mac", "ProcessInfo.isiOSAppOnMac")
        checkDebugger()
        return deduplicated()
      }
      checkJailbreakFiles()
      checkSymbolicLinks()
      checkSandboxWrite()
      checkFork()
      checkRootFileSystem()
      checkURLSchemes()
      checkDyldImages()
      checkEnvironment()
      checkFridaPort()
      checkDebugger()
    #endif
    return deduplicated()
  }

  private func add(_ type: String, _ code: String, _ detail: String) {
    findings.append(["type": type, "code": code, "detail": detail])
  }

  private func deduplicated() -> [[String: String]] {
    var seen = Set<String>()
    return findings.filter { seen.insert("\($0["type"]!)|\($0["code"]!)|\($0["detail"]!)").inserted }
  }

  // MARK: - Jailbreak

  private func checkJailbreakFiles() {
    for path in Self.jailbreakPaths where fileExists(path) {
      add(Self.root, "jailbreak_file", path)
    }
    for path in Self.hookPaths where fileExists(path) {
      add(Self.hook, "hook_file", path)
    }
  }

  /// Hook'lanmış tek bir API'nin sonucu gizlemesine karşı aynı dosya dört farklı yoldan sorgulanır.
  private func fileExists(_ path: String) -> Bool {
    if FileManager.default.fileExists(atPath: path) { return true }
    var info = stat()
    if stat(path, &info) == 0 { return true }
    if lstat(path, &info) == 0 { return true }
    if access(path, F_OK) == 0 { return true }
    if let file = fopen(path, "r") {
      fclose(file)
      return true
    }
    return false
  }

  /// Eski (rootful) jailbreak'ler sistem dizinlerini /var/stash altına taşıyıp sembolik link bırakır.
  private func checkSymbolicLinks() {
    for path in Self.symlinkPaths {
      var info = stat()
      if lstat(path, &info) == 0, (info.st_mode & S_IFMT) == S_IFLNK {
        add(Self.root, "symlink", path)
      }
    }
  }

  /// Sandbox sağlamsa uygulama kendi container'ı dışına yazamaz.
  private func checkSandboxWrite() {
    let path = "/private/" + UUID().uuidString
    do {
      try "integrity".write(toFile: path, atomically: true, encoding: .utf8)
      try? FileManager.default.removeItem(atPath: path)
      add(Self.root, "sandbox_write", path)
    } catch {}
  }

  /// Sandbox `fork`'u engeller; jailbreak'li cihazda başarılı olabilir.
  private func checkFork() {
    typealias ForkFunction = @convention(c) () -> pid_t
    guard let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "fork") else { return }
    let fork = unsafeBitCast(symbol, to: ForkFunction.self)
    let pid = fork()
    if pid == 0 {
      _exit(0)
    } else if pid > 0 {
      var status: Int32 = 0
      waitpid(pid, &status, 0)
      add(Self.root, "fork", "pid=\(pid)")
    }
  }

  /// Rootful jailbreak'ler kök dosya sistemini okuma-yazma olarak yeniden bağlar.
  private func checkRootFileSystem() {
    var info = statfs()
    guard statfs("/", &info) == 0 else { return }
    if (info.f_flags & UInt32(MNT_RDONLY)) == 0 {
      add(Self.root, "rw_rootfs", "statfs(/) MNT_RDONLY yok")
    }
  }

  /// Şemaların sorgulanabilmesi için uygulamanın Info.plist'inde `LSApplicationQueriesSchemes` olmalı;
  /// yoksa `canOpenURL` her zaman false döner (yanlış pozitif üretmez).
  private func checkURLSchemes() {
    let check = {
      for scheme in Self.jailbreakSchemes {
        guard let url = URL(string: "\(scheme)://package/com.example.package") else { continue }
        if UIApplication.shared.canOpenURL(url) {
          self.add(Self.root, "url_scheme", scheme)
        }
      }
    }
    if Thread.isMainThread {
      check()
    } else {
      DispatchQueue.main.sync(execute: check)
    }
  }

  // MARK: - Hook

  private func checkDyldImages() {
    let count = _dyld_image_count()
    for index in 0 ..< count {
      guard let cName = _dyld_get_image_name(index) else { continue }
      let name = String(cString: cName)
      let lower = name.lowercased()
      if let keyword = Self.suspiciousLibraries.first(where: { lower.contains($0) }) {
        let type = Self.jailbreakOnlyLibraries.contains(keyword) ? Self.root : Self.hook
        add(type, "injected_library", name)
      }
    }
  }

  private func checkEnvironment() {
    for variable in ["DYLD_INSERT_LIBRARIES", "_MSSafeMode", "_SafeMode", "_SubstituteSafeMode"] {
      if let value = getenv(variable) {
        add(Self.hook, "environment", "\(variable)=\(String(cString: value))")
      }
    }
  }

  private func checkFridaPort() {
    for port in Self.fridaPorts where isLocalPortOpen(port) {
      add(Self.hook, "frida_port", "127.0.0.1:\(port)")
    }
  }

  private func isLocalPortOpen(_ port: UInt16) -> Bool {
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    guard fd >= 0 else { return false }
    defer { close(fd) }
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = port.bigEndian
    address.sin_addr.s_addr = inet_addr("127.0.0.1")
    let result = withUnsafePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    return result == 0
  }

  // MARK: - Debugger

  private func checkDebugger() {
    var info = kinfo_proc()
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var size = MemoryLayout<kinfo_proc>.stride
    guard sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0) == 0 else { return }
    if (info.kp_proc.p_flag & P_TRACED) != 0 {
      add(Self.debugger, "ptrace", "P_TRACED")
    }
  }

  // MARK: - Listeler

  private static let jailbreakPaths = [
    // Paket yöneticileri ve araçlar
    "/Applications/Cydia.app", "/Applications/Sileo.app", "/Applications/Zebra.app", "/Applications/Installer.app",
    "/Applications/blackra1n.app", "/Applications/FakeCarrier.app", "/Applications/Icy.app",
    "/Applications/IntelliScreen.app", "/Applications/MxTube.app", "/Applications/RockApp.app",
    "/Applications/SBSettings.app", "/Applications/WinterBoard.app", "/Applications/Filza.app",
    "/Applications/checkra1n.app", "/Applications/Pwned.app",
    // Rootful jailbreak (unc0ver, checkra1n, Electra, Chimera, odyssey, Taurine)
    "/bin/bash", "/usr/sbin/sshd", "/usr/bin/sshd", "/usr/bin/ssh", "/usr/libexec/ssh-keysign",
    "/usr/libexec/sftp-server", "/etc/ssh/sshd_config", "/etc/apt", "/etc/apt/sources.list.d",
    "/etc/apt/sources.list.d/electra.list", "/etc/apt/sources.list.d/sileo.sources", "/etc/apt/undecimus/undecimus.list",
    "/private/etc/apt", "/private/etc/dpkg/origins/debian", "/private/var/lib/apt", "/private/var/lib/apt/",
    "/var/lib/apt", "/var/lib/cydia", "/private/var/lib/cydia", "/var/cache/apt", "/var/tmp/cydia.log",
    "/private/var/tmp/cydia.log", "/private/var/stash", "/private/var/mobile/Library/SBSettings/Themes",
    "/var/mobile/Library/Caches/com.saurik.Cydia", "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
    "/System/Library/LaunchDaemons/com.ikey.bbot.plist", "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/Library/MobileSubstrate/DynamicLibraries", "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
    "/Library/MobileSubstrate/DynamicLibraries/Veency.plist", "/usr/lib/libjailbreak.dylib", "/usr/share/jailbreak/injectme.plist",
    "/.installed_unc0ver", "/.bootstrapped_electra", "/.cydia_no_stash", "/.installed_odyssey", "/.installed_taurine",
    "/.bootstrapped", "/var/lib/undecimus/apt", "/jb/lzma", "/jb/jailbreakd.plist", "/jb/amfid_payload.dylib",
    "/jb/libjailbreak.dylib", "/jb/offsets.plist", "/var/checkra1n.dmg", "/var/binpack", "/var/binpack/Applications/loader.app",
    "/usr/bin/cycript", "/usr/local/bin/cycript", "/usr/lib/libcycript.dylib", "/usr/sbin/frida-server",
    "/private/var/mobile/Library/Preferences/com.saurik.Cydia.plist",
    // Rootless jailbreak (Dopamine, palera1n, XinaA15)
    "/var/jb", "/private/var/jb", "/var/jb/usr/bin/su", "/var/jb/Applications/Sileo.app", "/var/jb/Applications/Zebra.app",
    "/var/jb/.installed_dopamine", "/var/jb/.installed_palera1n", "/var/jb/basebin", "/private/preboot/jb",
  ]

  /// Jailbreak tespitini gizleyen veya uygulamaya kod enjekte eden tweak'ler.
  private static let hookPaths = [
    "/usr/lib/TweakInject", "/Library/TweakInject", "/usr/lib/TweakInject.dylib", "/usr/lib/substitute-inserter.dylib",
    "/usr/lib/substitute-loader.dylib", "/usr/lib/libsubstitute.dylib", "/usr/lib/libsubstrate.dylib",
    "/usr/lib/libhooker.dylib", "/usr/lib/ellekit", "/var/jb/usr/lib/libellekit.dylib", "/var/jb/usr/lib/TweakInject",
    "/var/jb/Library/MobileSubstrate/DynamicLibraries", "/usr/lib/frida", "/usr/lib/frida/frida-agent.dylib",
    "/Library/PreferenceBundles/LibertyPref.bundle", "/Library/PreferenceBundles/ShadowPreferences.bundle",
    "/Library/PreferenceBundles/ABypassPrefs.bundle", "/Library/PreferenceBundles/FlyJBPrefs.bundle",
    "/Library/PreferenceBundles/Cephei.bundle", "/Library/PreferenceBundles/SubstitutePrefs.bundle",
    "/Library/PreferenceBundles/libhbangprefs.bundle", "/usr/lib/ABDYLD.dylib", "/usr/lib/ABSubLoader.dylib",
    "/usr/lib/CepheiUI.framework/CepheiUI", "/usr/lib/Cephei.framework/Cephei",
  ]

  private static let symlinkPaths = [
    "/Applications", "/Library/Ringtones", "/Library/Wallpaper", "/usr/arm-apple-darwin9", "/usr/include",
    "/usr/libexec", "/usr/share", "/var/lib/undecimus/apt", "/var/jb",
  ]

  private static let jailbreakSchemes = [
    "cydia", "sileo", "zbra", "filza", "undecimus", "activator", "apt-repo",
  ]

  /// Yalnızca jailbreak'li cihazda yüklenebilen kütüphaneler; diğer eşleşmeler "hook" sayılır.
  private static let jailbreakOnlyLibraries: Set<String> = ["mobilesubstrate", "systemhook", "tweakinject", "/var/jb/"]

  private static let suspiciousLibraries = [
    "mobilesubstrate", "substrateloader", "substrateinserter", "substratebootstrap", "tweakinject", "libhooker",
    "ellekit", "libsubstitute", "substitute-inserter", "substitute-loader", "cephei", "rocketbootstrap",
    "libsparkapplist", "frida", "cynject", "libcycript", "sslkillswitch", "libertylite", "zzzzliberty",
    "shadow.dylib", "abypass", "a-bypass", "flyjb", "choicy", "preferenceloader", "systemhook", "/var/jb/",
    "hidejb", "jailprotect", "vnodebypass", "kernbypass", "rootlesshooks",
  ]

  private static let fridaPorts: [UInt16] = [27042, 27043]
}
