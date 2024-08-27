import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ICoreSharedPreferencesManager {
  Future<void> initialize();

  Set<String> getKeys();

  T? get<T extends Object>({required BaseSharedPrefKeys key});

  Future<bool> setInt({required BaseSharedPrefKeys key, required int value});

  int? getInt({required BaseSharedPrefKeys key});

  Future<bool> setString({required BaseSharedPrefKeys key, required String value});

  String? getString({required BaseSharedPrefKeys key});

  Future<bool> setBool({required BaseSharedPrefKeys key, required bool value});

  bool? getBool({required BaseSharedPrefKeys key});

  Future<bool> setDouble({required BaseSharedPrefKeys key, required double value});

  double? getDouble({required BaseSharedPrefKeys key});

  Future<bool> setStringList({required BaseSharedPrefKeys key, required List<String> value});

  List<String>? getStringList({required BaseSharedPrefKeys key});

  Future<bool> setObject<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required T value});

  T? getObject<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required T model});

  Future<bool> setObjectList<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required List<T> value});

  List<T>? getObjectList<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required T model});

  Future<bool> remove({required BaseSharedPrefKeys key});

  Future<bool> clear();

  bool containsKey({required BaseSharedPrefKeys key});

  Future<void> reload();
}

abstract class CoreSharedPreferencesManager implements ICoreSharedPreferencesManager {
  CoreSharedPreferencesManager({
    this.encryptionKey,
    this.encryptionIv,
  }) {
    if (encryptionKey != null && encryptionIv != null) {
      encrypter = enc.Encrypter(enc.AES(enc.Key.fromUtf8(encryptionKey!), mode: enc.AESMode.cbc));
    }
  }

  final String? encryptionKey;
  final String? encryptionIv;
  late final enc.Encrypter? encrypter;
  SharedPreferences? _prefs;

  @override
  @nonVirtual
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  @nonVirtual
  Set<String> getKeys() => _prefs!.getKeys();

  @override
  @nonVirtual
  T? get<T extends Object>({required BaseSharedPrefKeys key}) => _prefs!.get(key.keyName) as T?;

  @override
  @nonVirtual
  Future<bool> setInt({required BaseSharedPrefKeys key, required int value}) => _prefs!.setInt(key.keyName, value);

  @override
  @nonVirtual
  int? getInt({required BaseSharedPrefKeys key}) => _prefs!.getInt(key.keyName);

  @override
  @nonVirtual
  Future<bool> setString({required BaseSharedPrefKeys key, required String value}) {
    if (key.encrypt) {
      assert(encryptionKey != null && encryptionIv != null, 'Encryption key and iv must be provided for encryption');
      final encIv = enc.IV.fromBase64(encryptionIv!);
      final encrypted = encrypter!.encrypt(value, iv: encIv);
      return _prefs!.setString(key.keyName, encrypted.base64);
    }

    return _prefs!.setString(key.keyName, value);
  }

  @override
  @nonVirtual
  String? getString({required BaseSharedPrefKeys key}) {
    if (key.encrypt) {
      assert(encryptionKey != null && encryptionIv != null, 'Encryption key and iv must be provided for encryption');
      final valueString = _prefs!.getString(key.keyName);
      if (valueString.isNull) return null;
      final encIv = enc.IV.fromBase64(encryptionIv!);
      final decrypted = encrypter!.decrypt64(valueString!, iv: encIv);
      return decrypted;
    }
    return _prefs!.getString(key.keyName);
  }

  @override
  @nonVirtual
  Future<bool> setBool({required BaseSharedPrefKeys key, required bool value}) => _prefs!.setBool(key.keyName, value);

  @override
  @nonVirtual
  bool? getBool({required BaseSharedPrefKeys key}) => _prefs!.getBool(key.keyName);

  @override
  @nonVirtual
  Future<bool> setDouble({required BaseSharedPrefKeys key, required double value}) => _prefs!.setDouble(key.keyName, value);

  @override
  @nonVirtual
  double? getDouble({required BaseSharedPrefKeys key}) => _prefs!.getDouble(key.keyName);

  @override
  @nonVirtual
  Future<bool> setStringList({required BaseSharedPrefKeys key, required List<String> value}) => _prefs!.setStringList(key.keyName, value);

  @override
  @nonVirtual
  List<String>? getStringList({required BaseSharedPrefKeys key}) => _prefs!.getStringList(key.keyName);

  @override
  @nonVirtual
  Future<bool> setObject<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required T value}) {
    final valueString = jsonEncode(value.toJson());

    if (key.encrypt) {
      assert(encryptionKey != null && encryptionIv != null, 'Encryption key and iv must be provided for encryption');
      final encIv = enc.IV.fromBase64(encryptionIv!);
      final encrypted = encrypter!.encrypt(valueString, iv: encIv);
      return _prefs!.setString(key.keyName, encrypted.base64);
    }

    return _prefs!.setString(key.keyName, valueString);
  }

  @override
  @nonVirtual
  T? getObject<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required T model}) {
    final valueString = _prefs!.getString(key.keyName);
    if (valueString.isNull) return null;

    if (key.encrypt) {
      assert(encryptionKey != null && encryptionIv != null, 'Encryption key and iv must be provided for encryption');
      final encIv = enc.IV.fromBase64(encryptionIv!);

      final decrypted = encrypter!.decrypt64(valueString!, iv: encIv);
      return model.fromJson(jsonDecode(decrypted) as Map<String, Object?>);
    }

    return model.fromJson(jsonDecode(valueString!) as Map<String, Object?>);
  }

  @override
  @nonVirtual
  Future<bool> setObjectList<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required List<T> value}) {
    final valueString = jsonEncode(value.map((e) => e.toJson()).toList());

    if (key.encrypt) {
      assert(encryptionKey != null && encryptionIv != null, 'Encryption key and iv must be provided for encryption');

      final encIv = enc.IV.fromBase64(encryptionIv!);
      final encrypted = encrypter!.encrypt(valueString, iv: encIv);
      return _prefs!.setString(key.keyName, encrypted.base64);
    }

    return _prefs!.setString(key.keyName, valueString);
  }

  @override
  @nonVirtual
  List<T>? getObjectList<T extends BaseModel<T>>({required BaseSharedPrefKeys key, required T model}) {
    final valueString = _prefs!.getString(key.keyName);
    if (valueString.isNull) return null;

    if (key.encrypt) {
      assert(encryptionKey != null && encryptionIv != null, 'Encryption key and iv must be provided for encryption');

      final encIv = enc.IV.fromBase64(encryptionIv!);
      final decrypted = encrypter!.decrypt64(valueString!, iv: encIv);
      final list = (jsonDecode(decrypted) as List).cast<Map<String, Object?>>();
      return list.map((e) => model.fromJson(e)).toList();
    }

    final list = (jsonDecode(valueString!) as List).cast<Map<String, Object?>>();
    return list.map((e) => model.fromJson(e)).toList();
  }

  @override
  @nonVirtual
  Future<bool> remove({required BaseSharedPrefKeys key}) => _prefs!.remove(key.keyName);

  @override
  @nonVirtual
  Future<bool> clear() => _prefs!.clear();

  @override
  @nonVirtual
  bool containsKey({required BaseSharedPrefKeys key}) => _prefs!.containsKey(key.keyName);

  @override
  @nonVirtual
  Future<void> reload() => _prefs!.reload();
}
