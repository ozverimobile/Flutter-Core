package com.flutter.flutter_core.integrity

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import android.provider.Settings
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket
import java.util.concurrent.TimeUnit

/**
 * Root, hook (Frida/Xposed/LSPosed/Substrate), emülatör, debugger ve kilidi açık bootloader tespiti.
 *
 * Tek bir kontrol kolayca atlatılabildiği için birbirinden bağımsız birçok yöntem kullanılır:
 * dosya sistemi, `PATH`, sistem property'leri, mount tabloları, SELinux, paket yöneticisi,
 * `/proc/self` (maps, status, thread adları), stack trace ve Frida portu.
 *
 * Her bulgu `{type, code, detail}` map'i olarak döner; kararı Dart tarafı verir.
 * Ağ ve process çağrıları yaptığı için ana thread'de çalıştırılmamalıdır.
 */
internal class CoreDeviceIntegrityChecker(private val context: Context) {

    private val findings = ArrayList<Map<String, String>>()
    private val props: Map<String, String> by lazy { readSystemProperties() }

    fun check(): List<Map<String, String>> {
        findings.clear()
        runSafely { checkSuBinaries() }
        runSafely { checkWhichSu() }
        runSafely { checkRootArtifacts() }
        runSafely { checkRootPackages() }
        runSafely { checkDangerousProps() }
        runSafely { checkMounts() }
        runSafely { checkSelinux() }
        runSafely { checkPathWritable() }
        runSafely { checkHookingFrameworks() }
        runSafely { checkProcMaps() }
        runSafely { checkThreadNames() }
        runSafely { checkFridaPort() }
        runSafely { checkDebugger() }
        runSafely { checkEmulator() }
        runSafely { checkBootloader() }
        runSafely { checkDeveloperSettings() }
        return findings.distinct()
    }

    private fun add(type: String, code: String, detail: String) {
        findings.add(mapOf("type" to type, "code" to code, "detail" to detail))
    }

    // Bir kontrolün hata vermesi (SecurityException, SELinux engeli vb.) diğerlerini durdurmasın.
    private inline fun runSafely(block: () -> Unit) {
        try {
            block()
        } catch (_: Throwable) {
        }
    }

    // region Root

    private fun checkSuBinaries() {
        val dirs = SU_DIRS + System.getenv("PATH").orEmpty().split(':').filter { it.isNotBlank() }.map { it.trimEnd('/') + "/" }
        for (dir in dirs.distinct()) {
            for (binary in SU_BINARIES) {
                val path = dir + binary
                if (File(path).exists()) add(ROOT, "su_binary", path)
            }
        }
    }

    private fun checkWhichSu() {
        val output = exec("which", "su") ?: return
        if (output.isNotBlank()) add(ROOT, "which_su", output.trim())
    }

    private fun checkRootArtifacts() {
        for (path in ROOT_ARTIFACTS) {
            if (File(path).exists()) add(ROOT, "root_artifact", path)
        }
    }

    private fun checkRootPackages() {
        val pm = context.packageManager
        for (pkg in ROOT_PACKAGES) {
            if (isPackageInstalled(pm, pkg)) add(ROOT, "root_app", pkg)
        }
        for (pkg in HOOK_PACKAGES) {
            if (isPackageInstalled(pm, pkg)) add(HOOK, "hook_app", pkg)
        }
    }

    @Suppress("DEPRECATION")
    private fun isPackageInstalled(pm: PackageManager, pkg: String): Boolean = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getPackageInfo(pkg, PackageManager.PackageInfoFlags.of(0))
        } else {
            pm.getPackageInfo(pkg, 0)
        }
        true
    } catch (_: PackageManager.NameNotFoundException) {
        false
    }

    private fun checkDangerousProps() {
        if (Build.TAGS?.contains("test-keys") == true) add(ROOT, "test_keys", Build.TAGS)
        if (props["ro.debuggable"] == "1") add(ROOT, "ro_debuggable", "ro.debuggable=1")
        if (props["ro.secure"] == "0") add(ROOT, "ro_secure", "ro.secure=0")
        if (props["ro.build.selinux"] == "0") add(ROOT, "selinux_disabled", "ro.build.selinux=0")
        if (props["service.adb.root"] == "1") add(ROOT, "adb_root", "service.adb.root=1")
        // Magisk / KernelSU / APatch'in bıraktığı property'ler.
        for ((key, value) in props) {
            val k = key.lowercase()
            if (k.contains("magisk") || k.startsWith("init.svc.ksud") || k.contains("kernelsu") || k.contains("apatch")) {
                add(ROOT, "root_prop", "$key=$value")
            }
        }
    }

    private fun checkMounts() {
        val sources = listOf("/proc/self/mounts", "/proc/self/mountinfo", "/proc/mounts")
        for (source in sources) {
            val lines = readLines(source) ?: continue
            for (line in lines) {
                val lower = line.lowercase()
                val keyword = MOUNT_KEYWORDS.firstOrNull { lower.contains(it) }
                if (keyword != null) {
                    add(ROOT, "suspicious_mount", line.take(200))
                    continue
                }
                // /system veya /vendor okuma-yazma bağlanmış mı?
                val parts = line.split(' ')
                if (source.endsWith("mounts") && parts.size >= 4) {
                    val mountPoint = parts[1]
                    val options = parts[3].split(',')
                    if (mountPoint in READ_ONLY_MOUNTS && "rw" in options) {
                        add(ROOT, "rw_system", "$mountPoint ${parts[3]}")
                    }
                }
            }
        }
    }

    private fun checkSelinux() {
        val enforce = readLines("/sys/fs/selinux/enforce")?.firstOrNull()?.trim()
        if (enforce == "0") add(ROOT, "selinux_permissive", "/sys/fs/selinux/enforce=0")
        val status = exec("getenforce")?.trim()
        if (status != null && status.equals("Permissive", ignoreCase = true)) {
            add(ROOT, "selinux_permissive", "getenforce=$status")
        }
    }

    private fun checkPathWritable() {
        for (path in READ_ONLY_MOUNTS) {
            val dir = File(path)
            if (dir.exists() && dir.canWrite()) add(ROOT, "writable_system", path)
        }
    }

    // endregion

    // region Hook (Frida, Xposed, LSPosed, Substrate)

    private fun checkHookingFrameworks() {
        for (className in HOOK_CLASSES) {
            val found = try {
                Class.forName(className, false, ClassLoader.getSystemClassLoader())
                true
            } catch (_: Throwable) {
                try {
                    Class.forName(className, false, javaClass.classLoader)
                    true
                } catch (_: Throwable) {
                    false
                }
            }
            if (found) add(HOOK, "hook_class", className)
        }

        // Xposed/Substrate, çağrı zincirine kendi sınıflarını ekler.
        val stack = Throwable().stackTrace
        for (element in stack) {
            val name = element.className
            if (HOOK_STACK_KEYWORDS.any { name.contains(it, ignoreCase = true) }) {
                add(HOOK, "hook_stack", name)
            }
        }

        val env = System.getenv("CLASSPATH").orEmpty()
        if (env.contains("XposedBridge", ignoreCase = true)) add(HOOK, "xposed_classpath", env)
    }

    private fun checkProcMaps() {
        val lines = readLines("/proc/self/maps") ?: return
        val hits = LinkedHashSet<String>()
        for (line in lines) {
            val lower = line.lowercase()
            val keyword = MAPS_KEYWORDS.firstOrNull { lower.contains(it) } ?: continue
            val path = line.substringAfterLast(' ').ifBlank { keyword }
            hits.add(path)
        }
        for (hit in hits) add(HOOK, "injected_library", hit)
    }

    private fun checkThreadNames() {
        val tasks = File("/proc/self/task").listFiles() ?: return
        for (task in tasks) {
            val name = readLines("${task.path}/comm")?.firstOrNull()?.trim() ?: continue
            if (FRIDA_THREADS.any { name.contains(it, ignoreCase = true) }) {
                add(HOOK, "frida_thread", name)
            }
        }
    }

    private fun checkFridaPort() {
        for (port in FRIDA_PORTS) {
            try {
                Socket().use { socket ->
                    socket.connect(InetSocketAddress("127.0.0.1", port), 100)
                    add(HOOK, "frida_port", "127.0.0.1:$port")
                }
            } catch (_: Throwable) {
            }
        }
    }

    // endregion

    // region Debugger

    private fun checkDebugger() {
        if (Debug.isDebuggerConnected() || Debug.waitingForDebugger()) {
            add(DEBUGGER, "java_debugger", "Debug.isDebuggerConnected")
        }
        // gdb, strace, frida-trace gibi ptrace kullanan araçlar.
        val tracer = readLines("/proc/self/status")
            ?.firstOrNull { it.startsWith("TracerPid:") }
            ?.substringAfter(':')?.trim()?.toIntOrNull() ?: 0
        if (tracer != 0) add(DEBUGGER, "ptrace", "TracerPid=$tracer")

        // Release build'in debuggable olması, APK'nın yeniden paketlendiğine işaret eder.
        val debuggable = (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (debuggable && !isDebugBuild()) add(DEBUGGER, "debuggable_release", context.packageName)
    }

    // Uygulamanın BuildConfig.DEBUG değeri; okunamazsa debug kabul edilir (yanlış pozitif vermemek için).
    private fun isDebugBuild(): Boolean = try {
        val buildConfig = Class.forName("${context.packageName}.BuildConfig")
        buildConfig.getField("DEBUG").getBoolean(null)
    } catch (_: Throwable) {
        true
    }

    // endregion

    // region Emülatör

    private fun checkEmulator() {
        val fingerprint = Build.FINGERPRINT.orEmpty()
        val model = Build.MODEL.orEmpty()
        val manufacturer = Build.MANUFACTURER.orEmpty()
        val brand = Build.BRAND.orEmpty()
        val device = Build.DEVICE.orEmpty()
        val product = Build.PRODUCT.orEmpty()
        val hardware = Build.HARDWARE.orEmpty()
        val board = Build.BOARD.orEmpty()

        val signals = ArrayList<String>()
        if (fingerprint.startsWith("generic") || fingerprint.startsWith("unknown") || fingerprint.contains("emulator") || fingerprint.contains("sdk_gphone")) {
            signals.add("fingerprint=$fingerprint")
        }
        if (model.contains("google_sdk") || model.contains("Emulator") || model.contains("Android SDK built for") || model.contains("sdk_gphone")) {
            signals.add("model=$model")
        }
        if (manufacturer.contains("Genymotion", ignoreCase = true)) signals.add("manufacturer=$manufacturer")
        if (brand.startsWith("generic") && device.startsWith("generic")) signals.add("brand/device=generic")
        if (hardware in EMULATOR_HARDWARE || hardware.contains("nox", ignoreCase = true) || hardware.contains("vbox", ignoreCase = true)) {
            signals.add("hardware=$hardware")
        }
        if (product == "sdk" || EMULATOR_PRODUCTS.any { product.contains(it, ignoreCase = true) }) signals.add("product=$product")
        if (board.contains("nox", ignoreCase = true)) signals.add("board=$board")
        if (props["ro.kernel.qemu"] == "1" || props["ro.boot.qemu"] == "1") signals.add("ro.kernel.qemu=1")
        props["ro.hardware.virtual_device"]?.takeIf { it.isNotBlank() }?.let { signals.add("ro.hardware.virtual_device=$it") }

        for (signal in signals) add(EMULATOR, "emulator_build", signal)
        for (path in EMULATOR_FILES) {
            if (File(path).exists()) add(EMULATOR, "emulator_file", path)
        }
    }

    // endregion

    // region Bootloader / geliştirici ayarları

    private fun checkBootloader() {
        val state = props["ro.boot.verifiedbootstate"]
        if (state != null && state.isNotBlank() && state != "green") {
            add(BOOTLOADER, "verified_boot", "ro.boot.verifiedbootstate=$state")
        }
        if (props["ro.boot.flash.locked"] == "0") add(BOOTLOADER, "flash_unlocked", "ro.boot.flash.locked=0")
        if (props["ro.boot.vbmeta.device_state"] == "unlocked") {
            add(BOOTLOADER, "vbmeta_unlocked", "ro.boot.vbmeta.device_state=unlocked")
        }
    }

    private fun checkDeveloperSettings() {
        val resolver = context.contentResolver
        if (Settings.Global.getInt(resolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) != 0) {
            add(DEVELOPER_MODE, "developer_options", "Settings.Global.DEVELOPMENT_SETTINGS_ENABLED=1")
        }
        if (Settings.Global.getInt(resolver, Settings.Global.ADB_ENABLED, 0) != 0) {
            add(ADB, "adb_enabled", "Settings.Global.ADB_ENABLED=1")
        }
    }

    // endregion

    // region Yardımcılar

    private fun readSystemProperties(): Map<String, String> {
        val output = exec("getprop") ?: return emptyMap()
        val regex = Regex("""^\[(.+?)]: \[(.*)]$""")
        val result = HashMap<String, String>()
        for (line in output.lineSequence()) {
            val match = regex.find(line.trim()) ?: continue
            result[match.groupValues[1]] = match.groupValues[2]
        }
        return result
    }

    private fun readLines(path: String): List<String>? = try {
        File(path).takeIf { it.canRead() }?.readLines()
    } catch (_: Throwable) {
        null
    }

    private fun exec(vararg command: String): String? {
        var process: Process? = null
        return try {
            process = ProcessBuilder(*command).redirectErrorStream(true).start()
            val output = process.inputStream.bufferedReader().use { it.readText() }
            if (!process.waitFor(2, TimeUnit.SECONDS)) null else output
        } catch (_: Throwable) {
            null
        } finally {
            process?.destroy()
        }
    }

    // endregion

    companion object {
        const val ROOT = "rootOrJailbreak"
        const val HOOK = "hooking"
        const val EMULATOR = "emulator"
        const val DEBUGGER = "debugger"
        const val BOOTLOADER = "bootloaderUnlocked"
        const val DEVELOPER_MODE = "developerMode"
        const val ADB = "adbEnabled"

        private val SU_BINARIES = listOf("su", "magisk", "magiskpolicy", "ksud", "daemonsu", "supolicy")

        private val SU_DIRS = listOf(
            "/data/local/", "/data/local/bin/", "/data/local/xbin/", "/sbin/", "/su/bin/",
            "/system/bin/", "/system/bin/.ext/", "/system/bin/failsafe/", "/system/sd/xbin/",
            "/system/usr/we-need-root/", "/system/xbin/", "/system/app/", "/cache/", "/data/",
            "/dev/", "/odm/bin/", "/product/bin/", "/system_ext/bin/", "/vendor/bin/", "/vendor/xbin/",
            "/apex/com.android.runtime/bin/", "/data/adb/", "/data/adb/magisk/", "/data/adb/ksu/bin/",
            "/data/adb/ap/bin/", "/debug_ramdisk/",
        )

        private val ROOT_ARTIFACTS = listOf(
            "/system/app/Superuser.apk", "/system/app/SuperSU.apk", "/system/app/SuperSU",
            "/system/etc/init.d/99SuperSUDaemon", "/system/xbin/daemonsu", "/system/bin/.ext/.su",
            "/system/etc/.has_su_daemon", "/system/etc/.installed_su_daemon", "/dev/com.koushikdutta.superuser.daemon/",
            "/sbin/.magisk", "/sbin/.core", "/cache/.disable_magisk", "/cache/magisk.log", "/data/adb/magisk",
            "/data/adb/magisk.db", "/data/adb/modules", "/data/adb/post-fs-data.d", "/data/adb/service.d",
            "/data/adb/ksu", "/data/adb/ksud", "/data/adb/ap", "/data/adb/apd", "/dev/.magisk.unblock",
            "/init.magisk.rc", "/system/addon.d/99-magisk.sh", "/debug_ramdisk/.magisk", "/system/lib/libsupol.so",
            "/system/lib64/libsupol.so", "/su", "/magisk",
        )

        private val ROOT_PACKAGES = listOf(
            "com.topjohnwu.magisk", "io.github.vvb2060.magisk", "io.github.huskydg.magisk",
            "me.weishu.kernelsu", "me.bmax.apatch", "com.rifsxd.ksunext",
            "eu.chainfire.supersu", "com.noshufou.android.su", "com.noshufou.android.su.elite",
            "com.koushikdutta.superuser", "com.thirdparty.superuser", "com.yellowes.su",
            "com.kingroot.kinguser", "com.kingo.root", "com.smedialink.oneclickroot",
            "com.zhiqupk.root.global", "com.alephzain.framaroot", "com.koushikdutta.rommanager",
            "com.koushikdutta.rommanager.license", "com.dimonvideo.luckypatcher", "com.chelpus.lackypatch",
            "com.ramdroid.appquarantine", "com.ramdroid.appquarantinepro", "com.android.vending.billing.InAppBillingService.COIN",
            "com.android.vending.billing.InAppBillingService.LUCK", "com.chelpus.luckypatcher", "cc.madkite.freedom",
            "com.devadvance.rootcloak", "com.devadvance.rootcloakplus", "com.amphoras.hidemyroot",
            "com.amphoras.hidemyrootadfree", "com.formyhm.hiderootPremium", "com.formyhm.hideroot",
            "com.zachspong.temprootremovejb", "com.tsng.hidemyapplist",
        )

        private val HOOK_PACKAGES = listOf(
            "de.robv.android.xposed.installer", "org.meowcat.edxposed.manager", "org.lsposed.manager",
            "org.lsposed.lspatch", "top.canyie.dreamland.manager", "com.solohsu.android.edxp.manager",
            "com.saurik.substrate", "io.va.exposed", "io.va.exposed64",
        )

        private val HOOK_CLASSES = listOf(
            "de.robv.android.xposed.XposedBridge", "de.robv.android.xposed.XposedHelpers",
            "org.lsposed.lspd.core.Main", "org.lsposed.lspatch.loader.LSPApplication",
            "com.saurik.substrate.MS", "com.elderdrivers.riru.edxp.config.EdXpConfigGlobal",
        )

        private val HOOK_STACK_KEYWORDS = listOf(
            "de.robv.android.xposed", "com.saurik.substrate", "LSPHooker", "org.lsposed", "EdHooker", "me.weishu.epic",
        )

        private val MAPS_KEYWORDS = listOf(
            "frida", "gum-js-loop", "gadget.so", "linjector", "xposed", "lspd", "liblsp", "edxp",
            "libriru", "riru_", "zygisk", "libsubstrate", "libsandhook", "libepic", "libwhale",
            "libpine", "libdobby", "libshadowhook", "/data/local/tmp/",
        )

        private val FRIDA_THREADS = listOf("gum-js-loop", "pool-frida", "frida", "linjector")

        private val FRIDA_PORTS = listOf(27042, 27043)

        private val MOUNT_KEYWORDS = listOf(
            "magisk", "/sbin/.core", "core/mirror", "core/img", "kernelsu", "/data/adb/modules",
            "/debug_ramdisk", "zygisk", "apatch",
        )

        private val READ_ONLY_MOUNTS = setOf(
            "/system", "/system/bin", "/system/sbin", "/system/xbin", "/vendor/bin", "/sbin", "/etc", "/vendor",
        )

        private val EMULATOR_HARDWARE = setOf("goldfish", "ranchu", "vbox86", "ttVM_x86", "cutf_cvm")

        private val EMULATOR_PRODUCTS = listOf(
            "google_sdk", "sdk_x86", "sdk_gphone", "vbox86p", "emulator", "simulator", "genymotion",
        )

        private val EMULATOR_FILES = listOf(
            "/dev/socket/qemud", "/dev/qemu_pipe", "/dev/goldfish_pipe", "/system/lib/libc_malloc_debug_qemu.so",
            "/sys/qemu_trace", "/system/bin/qemu-props", "/system/bin/qemud", "/dev/socket/genyd",
            "/dev/socket/baseband_genyd", "/system/bin/androVM-prop", "/system/bin/microvirt-prop",
            "/system/lib/libdroid4x.so", "/system/bin/windroyed", "/system/bin/nox-prop", "/system/bin/noxd",
            "/system/lib/libnoxspeedup.so", "/system/bin/ldinit", "/system/bin/ldmountsf",
            "/data/bluestacks.prop", "/system/bin/bstshutdown", "/system/lib/vboxsf.ko", "/system/lib/vboxguest.ko",
            "/fstab.vbox86", "/init.vbox86.rc", "/ueventd.vbox86.rc", "/fstab.ranchu", "/init.ranchu.rc",
        )
    }
}
