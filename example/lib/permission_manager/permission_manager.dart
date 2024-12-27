import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const PermissionManagerApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
final _permissionManager = CorePermissionManager(navigatorKey: navigatorKey);

class PermissionManagerApp extends StatefulWidget {
  const PermissionManagerApp({super.key});

  @override
  State<PermissionManagerApp> createState() => _PermissionManagerAppState();
}

class _PermissionManagerAppState extends State<PermissionManagerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      navigatorKey: navigatorKey,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Permission Manager'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NotificationPermissionButton(),
                  _CameraPermissionButton(),
                  _PhotosPermissionButton(),
                  _LocationPermissionButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationPermissionButton extends StatelessWidget {
  const _NotificationPermissionButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (kDebugMode) {
          print(
            await _permissionManager.requestPermission(
              context: context,
              showAskLaterOption: true,
              permission: CorePermission.notification,
            ),
          );
        }
      },
      child: const Text('Request Notification Permission'),
    );
  }
}

class _CameraPermissionButton extends StatelessWidget {
  const _CameraPermissionButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (kDebugMode) {
          print(
            await _permissionManager.requestPermission(
              context: context,
              showAskLaterOption: true,
              permission: CorePermission.camera,
            ),
          );
        }
      },
      child: const Text('Request Camera Permission'),
    );
  }
}

class _PhotosPermissionButton extends StatelessWidget {
  const _PhotosPermissionButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (kDebugMode) {
          print(
            await _permissionManager.requestPermission(
              context: context,
              showAskLaterOption: true,
              permission: CorePermission.photos,
            ),
          );
        }
      },
      child: const Text('Request Photos Permission'),
    );
  }
}

class _LocationPermissionButton extends StatelessWidget {
  const _LocationPermissionButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (kDebugMode) {
          print(
            await _permissionManager.requestPermission(
              context: context,
              permission: CorePermission.location,
            ),
          );
        }
      },
      child: const Text('Request Location Permission'),
    );
  }
}
