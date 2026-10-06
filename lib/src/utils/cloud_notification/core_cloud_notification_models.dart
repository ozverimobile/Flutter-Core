import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_core/src/utils/cloud_notification/core_cloud_notification.dart';

/// OneSignal `OSLogLevel` ile aynı sıra.
enum CoreCloudNotificationLogLevel { none, fatal, error, warn, info, debug, verbose }

/// Gelen bir bildirim (OneSignal `OSNotification` karşılığı).
final class CoreNotification {
  CoreNotification.fromMap(Map<Object?, Object?> map)
    : notificationId = map['notificationId']! as String,
      title = map['title'] as String?,
      subtitle = map['subtitle'] as String?,
      body = map['body'] as String?,
      launchUrl = map['launchUrl'] as String?,
      bigPicture = map['bigPicture'] as String?,
      rawPayload = map['rawPayload'] as String?,
      sound = map['sound'] as String?,
      category = map['category'] as String?,
      threadId = map['threadId'] as String?,
      badge = (map['badge'] as num?)?.toInt(),
      contentAvailable = map['contentAvailable'] as bool? ?? false,
      mutableContent = map['mutableContent'] as bool? ?? false,
      androidNotificationId = (map['androidNotificationId'] as num?)?.toInt(),
      androidChannelId = map['androidChannelId'] as String?,
      buttons = [
        for (final button in map['buttons'] as List<Object?>? ?? const <Object?>[])
          CoreNotificationButton.fromMap(button! as Map<Object?, Object?>),
      ],
      additionalData = _additionalData(map['additionalData']);

  /// Backend'in bildirim id'si (`_nid`).
  final String notificationId;
  final String? title;

  /// Sadece iOS.
  final String? subtitle;
  final String? body;

  /// Gönderimde girilen `url` (deep link veya web adresi).
  final String? launchUrl;

  /// Gönderimde girilen `imageUrl`.
  final String? bigPicture;

  /// Platformdan gelen ham payload (JSON).
  final String? rawPayload;

  /// Sadece iOS.
  final String? sound;
  final String? category;
  final String? threadId;
  final int? badge;
  final bool contentAvailable;
  final bool mutableContent;

  /// Sadece Android.
  final int? androidNotificationId;
  final String? androidChannelId;

  /// Aksiyon butonları (en fazla 3). Basılan butonun id'si `CoreNotificationClickResult.actionId`.
  final List<CoreNotificationButton> buttons;

  /// Gönderimde girilen custom data; yoksa `null` (OneSignal ile aynı). İç içe nesneler
  /// `Map<String, dynamic>` olarak gelir.
  final Map<String, dynamic>? additionalData;

  /// `preventDefault()` ile engellenmiş bildirimi göstermek için.
  void display() => CoreCloudNotification.Notifications.displayNotification(notificationId);

  String jsonRepresentation() => jsonEncode(<String, Object?>{
    'notificationId': notificationId,
    'title': title,
    'subtitle': subtitle,
    'body': body,
    'launchUrl': launchUrl,
    'bigPicture': bigPicture,
    'additionalData': additionalData,
    'rawPayload': rawPayload,
  });

  @override
  String toString() => 'CoreNotification(${jsonRepresentation()})';

  static Map<String, dynamic>? _additionalData(Object? value) {
    if (value is! Map || value.isEmpty) return null;
    return _deepMap(value);
  }

  static Map<String, dynamic> _deepMap(Map<Object?, Object?> map) => <String, dynamic>{
    for (final entry in map.entries) '${entry.key}': _deepValue(entry.value),
  };

  static dynamic _deepValue(Object? value) {
    if (value is Map) return _deepMap(value);
    if (value is List) return value.map(_deepValue).toList();
    return value;
  }
}

/// Bildirimdeki aksiyon butonu (OneSignal `OSActionButton`).
final class CoreNotificationButton {
  CoreNotificationButton.fromMap(Map<Object?, Object?> map)
    : id = map['id']! as String,
      text = map['text'] as String? ?? map['id']! as String,
      url = map['url'] as String?;

  final String id;
  final String text;

  /// Butona basılınca açılacak adres; http(s) ise tarayıcıda açılır, değilse `result.url` ile gelir.
  final String? url;
}

/// Uygulama ön plandayken bildirim gelince (OneSignal `OSNotificationWillDisplayEvent`).
///
/// Listener içinde **senkron** olarak [preventDefault] çağrılırsa bildirim gösterilmez; daha sonra
/// `notification.display()` ile gösterilebilir. Hiçbir listener engellemezse bildirim gösterilir.
final class CoreNotificationWillDisplayEvent {
  CoreNotificationWillDisplayEvent(this.notification);

  final CoreNotification notification;
  bool _prevented = false;

  bool get isPrevented => _prevented;

  void preventDefault() => _prevented = true;
}

final class CoreNotificationClickResult {
  CoreNotificationClickResult.fromMap(Map<Object?, Object?> map)
    : actionId = map['actionId'] as String?,
      url = map['url'] as String?;

  /// Aksiyon butonuna basıldıysa butonun id'si; bildirimin kendisine dokunulduysa `null`.
  final String? actionId;

  /// Butona basıldıysa butonun url'i, yoksa bildirimin `launchUrl`'i.
  final String? url;
}

/// Bildirime dokunulunca (OneSignal `OSNotificationClickEvent`).
final class CoreNotificationClickEvent {
  CoreNotificationClickEvent.fromMap(Map<Object?, Object?> map)
    : notification = CoreNotification.fromMap(map['notification']! as Map<Object?, Object?>),
      result = CoreNotificationClickResult.fromMap(map['result'] as Map<Object?, Object?>? ?? const {});

  final CoreNotification notification;
  final CoreNotificationClickResult result;
}

/// OneSignal `OSPushSubscriptionState`.
@immutable
final class CorePushSubscriptionState {
  const CorePushSubscriptionState({this.id, this.token, this.optedIn = false});

  CorePushSubscriptionState.fromMap(Map<Object?, Object?> map)
    : id = map['id'] as String?,
      token = map['token'] as String?,
      optedIn = map['optedIn'] as bool? ?? false;

  /// Backend'deki cihaz kaydının id'si (panelde hedef olarak seçilen id).
  final String? id;

  /// APNs (hex) veya FCM token'ı.
  final String? token;

  /// Bildirim izni var ve abonelik açık.
  final bool optedIn;

  @override
  bool operator ==(Object other) =>
      other is CorePushSubscriptionState && other.id == id && other.token == token && other.optedIn == optedIn;

  @override
  int get hashCode => Object.hash(id, token, optedIn);

  @override
  String toString() => 'CorePushSubscriptionState(id: $id, optedIn: $optedIn, token: $token)';
}

/// OneSignal `OSPushSubscriptionChangedState`.
final class CorePushSubscriptionChangedState {
  const CorePushSubscriptionChangedState({required this.previous, required this.current});

  final CorePushSubscriptionState previous;
  final CorePushSubscriptionState current;
}
