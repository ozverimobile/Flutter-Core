import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const DeviceIntegrityApp());
}

class DeviceIntegrityApp extends StatefulWidget {
  const DeviceIntegrityApp({super.key});

  @override
  State<DeviceIntegrityApp> createState() => _DeviceIntegrityAppState();
}

class _DeviceIntegrityAppState extends State<DeviceIntegrityApp> {
  CoreDeviceIntegrityResult? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _loading = true);
    final result = await CoreDeviceIntegrity.check();
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Device Integrity')),
        floatingActionButton: FloatingActionButton(
          onPressed: _loading ? null : _check,
          child: const Icon(Icons.refresh),
        ),
        body: result == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    leading: Icon(
                      result.isCompromised ? Icons.gpp_bad : Icons.verified_user,
                      color: result.isCompromised ? Colors.red : Colors.green,
                    ),
                    title: Text(result.isCompromised ? 'Cihaz güvenli değil' : 'Root / jailbreak / hook bulunamadı'),
                    subtitle: result.isCheckFailed ? Text('Kontrol hatası: ${result.error}') : null,
                  ),
                  for (final type in CoreIntegrityThreatType.values.where((t) => t != CoreIntegrityThreatType.unknown))
                    CheckboxListTile(
                      value: result.has(type),
                      onChanged: null,
                      title: Text(type.name),
                    ),
                  const Divider(),
                  for (final finding in result.findings)
                    ListTile(
                      dense: true,
                      title: Text('${finding.type.name} • ${finding.code}'),
                      subtitle: Text(finding.detail),
                    ),
                ],
              ),
      ),
    );
  }
}
