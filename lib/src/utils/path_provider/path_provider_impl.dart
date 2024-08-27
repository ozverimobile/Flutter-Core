import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

abstract interface class ICorePathProvider {
  Future<Directory> getApplicationDocumentsDirectory();

  Future<Directory> getApplicationSupportDirectory();

  Future<Directory> getLibraryDirectory();

  Future<Directory> getTemporaryDirectory();

  Future<Directory?> getExternalStorageDirectory();

  Future<Directory> getDownloadsDirectory();
}

class CorePathProvider implements ICorePathProvider {
  CorePathProvider._();

  static final instance = CorePathProvider._();

  @override
  Future<Directory> getApplicationDocumentsDirectory() {
    return path_provider.getApplicationDocumentsDirectory();
  }

  @override
  Future<Directory> getLibraryDirectory() {
    return path_provider.getLibraryDirectory();
  }

  @override
  Future<Directory> getApplicationSupportDirectory() {
    return path_provider.getApplicationSupportDirectory();
  }

  @override
  Future<Directory> getTemporaryDirectory() {
    return path_provider.getTemporaryDirectory();
  }

  @override
  Future<Directory?> getExternalStorageDirectory() {
    return path_provider.getExternalStorageDirectory();
  }

  @override
  Future<Directory> getDownloadsDirectory() {
    if (Platform.isIOS || Platform.isMacOS) {
      return path_provider.getApplicationDocumentsDirectory();
    }
    return SynchronousFuture(Directory('/storage/emulated/0/Download'));
  }
}
