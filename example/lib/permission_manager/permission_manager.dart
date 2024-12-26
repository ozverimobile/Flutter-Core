import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/permission_manager/permission_manager_keys.dart';

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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationPermissionButton extends StatefulWidget {
  const _NotificationPermissionButton();

  @override
  State<_NotificationPermissionButton> createState() => _NotificationPermissionButtonState();
}

class _NotificationPermissionButtonState extends State<_NotificationPermissionButton> {
  CorePermissionStatus? notificationPermissionStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(notificationPermissionStatus.toString(), key: Key(PermissionManagerKeys.notificationPermissionStatusKey.rawValue)),
        ElevatedButton(
          key: Key(PermissionManagerKeys.notificationPermissionButtonKey.toString()),
          onPressed: () async {
            notificationPermissionStatus = await _permissionManager.requestPermission(
              context: context,
              showAskLaterOption: true,
              permission: CorePermission.notification,
            );

            setState(() {});
          },
          child: const Text('Request Notification Permission'),
        ),
      ],
    );
  }
}

class _CameraPermissionButton extends StatefulWidget {
  const _CameraPermissionButton();

  @override
  State<_CameraPermissionButton> createState() => _CameraPermissionButtonState();
}

class _CameraPermissionButtonState extends State<_CameraPermissionButton> {
  CorePermissionStatus? cameraPermissionStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(cameraPermissionStatus.toString(), key: Key(PermissionManagerKeys.cameraPermissionStatusKey.rawValue)),
        ElevatedButton(
          key: Key(PermissionManagerKeys.cameraPermissionButtonKey.rawValue),
          onPressed: () async {
            cameraPermissionStatus = await _permissionManager.requestPermission(
              context: context,
              showAskLaterOption: true,
              permission: CorePermission.camera,
            );

            setState(() {});
          },
          child: const Text('Request Camera Permission'),
        ),
      ],
    );
  }
}

class _PhotosPermissionButton extends StatefulWidget {
  const _PhotosPermissionButton();

  @override
  State<_PhotosPermissionButton> createState() => _PhotosPermissionButtonState();
}

class _PhotosPermissionButtonState extends State<_PhotosPermissionButton> {
  CorePermissionStatus? photosPermissionStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(photosPermissionStatus.toString(), key: Key(PermissionManagerKeys.photosPermissionStatusKey.rawValue)),
        ElevatedButton(
          key: Key(PermissionManagerKeys.photosPermissionButtonKey.rawValue),
          onPressed: () async {
            photosPermissionStatus = await _permissionManager.requestPermission(
              context: context,
              showAskLaterOption: true,
              permission: CorePermission.photos,
            );

            setState(() {});
          },
          child: const Text('Request Photos Permission'),
        ),
      ],
    );
  }
}
