import 'dart:io';
import 'dart:ui';

import 'package:flutter_core/src/utils/share/protocol/protocol.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ICoreShare {
  Future<CoreShareResultStatus> share(String text, {String? subject});

  Future<CoreShareResultStatus> shareUri(Uri uri);

  Future<CoreShareResultStatus> shareFile(List<File> files, {String? subject, String? text});
}

class CoreShare implements ICoreShare {
  CoreShare._();

  static final instance = CoreShare._();

  static final SharePlus _shareInstance = SharePlus.instance;

  @override
  Future<CoreShareResultStatus> share(String text, {String? subject}) async {
    final result = await _shareInstance.share(ShareParams(text: text, subject: subject, sharePositionOrigin: _sharePositionOrigin));
    return CoreShareResultStatus.values[result.status.index];
  }

  @override
  Future<CoreShareResultStatus> shareFile(List<File> files, {String? subject, String? text}) async {
    final xFiles = files.map((file) => XFile(file.path)).toList();
    final result = await _shareInstance.share(ShareParams(files: xFiles, subject: subject, text: text, sharePositionOrigin: _sharePositionOrigin));
    return CoreShareResultStatus.values[result.status.index];
  }

  @override
  Future<CoreShareResultStatus> shareUri(Uri uri) async {
    final result = await _shareInstance.share(ShareParams(uri: uri, sharePositionOrigin: _sharePositionOrigin));
    return CoreShareResultStatus.values[result.status.index];
  }

  Rect get _sharePositionOrigin => const Rect.fromLTWH(0, 0, 300, 500);
}
