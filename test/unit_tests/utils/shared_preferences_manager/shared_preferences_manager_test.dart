import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CoreSharedPreferencesManager prefsManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefsManager = _CoreSharedPreferencesManager(
      encryptionKey: 'testEncryptionKey',
      encryptionIv: 'testEncryptionIv',
    );
    await prefsManager.initialize();
  });

  group('Core Shared Preferences Manager', () {
    test('Should initialize manager successfully', () {
      expect(prefsManager, isNotNull);
    });

    test('Should return empty keys when initialized', () {
      expect(prefsManager.getKeys(), isEmpty);
    });

    test('Should correctly set and get integer value', () async {
      await prefsManager.setInt(key: _DigitalFormLocalDSKeys.testInt, value: 1);
      final value = prefsManager.getInt(key: _DigitalFormLocalDSKeys.testInt);
      expect(value, 1);
    });

    test('Should overwrite integer value correctly', () async {
      await prefsManager.setInt(key: _DigitalFormLocalDSKeys.testInt, value: 1);
      await prefsManager.setInt(key: _DigitalFormLocalDSKeys.testInt, value: 2);
      final value = prefsManager.getInt(key: _DigitalFormLocalDSKeys.testInt);
      expect(value, 2);
    });

    test('Should return null when integer value does not exist', () {
      final value = prefsManager.getInt(key: _DigitalFormLocalDSKeys.testInt);
      expect(value, isNull);
    });

    test('Should correctly set and get string value', () async {
      await prefsManager.setString(key: _DigitalFormLocalDSKeys.testString, value: 'test');
      final value = prefsManager.getString(key: _DigitalFormLocalDSKeys.testString);
      expect(value, 'test');
    });

    test('Should overwrite string value correctly', () async {
      await prefsManager.setString(key: _DigitalFormLocalDSKeys.testString, value: 'test');
      await prefsManager.setString(key: _DigitalFormLocalDSKeys.testString, value: 'test2');
      final value = prefsManager.getString(key: _DigitalFormLocalDSKeys.testString);
      expect(value, 'test2');
    });

    test('Should return null when string value does not exist', () {
      final value = prefsManager.getString(key: _DigitalFormLocalDSKeys.testString);
      expect(value, isNull);
    });

    test('Should correctly set and get boolean value', () async {
      await prefsManager.setBool(key: _DigitalFormLocalDSKeys.testBool, value: true);
      final value = prefsManager.getBool(key: _DigitalFormLocalDSKeys.testBool);
      expect(value, true);
    });

    test('Should overwrite boolean value correctly', () async {
      await prefsManager.setBool(key: _DigitalFormLocalDSKeys.testBool, value: true);
      await prefsManager.setBool(key: _DigitalFormLocalDSKeys.testBool, value: false);
      final value = prefsManager.getBool(key: _DigitalFormLocalDSKeys.testBool);
      expect(value, false);
    });

    test('Should return null when boolean value does not exist', () {
      final value = prefsManager.getBool(key: _DigitalFormLocalDSKeys.testBool);
      expect(value, isNull);
    });

    test('Should correctly set and get double value', () async {
      await prefsManager.setDouble(key: _DigitalFormLocalDSKeys.testDouble, value: 1.5);
      final value = prefsManager.getDouble(key: _DigitalFormLocalDSKeys.testDouble);
      expect(value, 1.5);
    });

    test('Should overwrite double value correctly', () async {
      await prefsManager.setDouble(key: _DigitalFormLocalDSKeys.testDouble, value: 1.5);
      await prefsManager.setDouble(key: _DigitalFormLocalDSKeys.testDouble, value: 2.5);
      final value = prefsManager.getDouble(key: _DigitalFormLocalDSKeys.testDouble);
      expect(value, 2.5);
    });

    test('Should return null when double value does not exist', () {
      final value = prefsManager.getDouble(key: _DigitalFormLocalDSKeys.testDouble);
      expect(value, isNull);
    });

    test('Should correctly set and get object value', () async {
      const model = _BaseModel();
      await prefsManager.setObject(key: _DigitalFormLocalDSKeys.testString, value: model);
      final value = prefsManager.getObject<_BaseModel>(key: _DigitalFormLocalDSKeys.testString, model: const _BaseModel());
      expect(value, model);
    });

    test('Should overwrite object value correctly', () async {
      const model1 = _BaseModel(doubleValue: 999, intValue: 999, boolValue: false, stringValue: '999');
      const model2 = _BaseModel(doubleValue: 888, intValue: 888, stringValue: '888');
      await prefsManager.setObject(key: _DigitalFormLocalDSKeys.testString, value: model1);
      await prefsManager.setObject(key: _DigitalFormLocalDSKeys.testString, value: model2);
      final value = prefsManager.getObject<_BaseModel>(key: _DigitalFormLocalDSKeys.testString, model: const _BaseModel());
      expect(value, model2);
    });

    test('Should return null when object value does not exist', () {
      final value = prefsManager.getObject<_BaseModel>(key: _DigitalFormLocalDSKeys.testString, model: const _BaseModel());
      expect(value, isNull);
    });

    test('Should correctly set and get object list value', () async {
      const model1 = _BaseModel(doubleValue: 999, intValue: 999, boolValue: false, stringValue: '999');
      const model2 = _BaseModel(doubleValue: 888, intValue: 888, stringValue: '888');
      await prefsManager.setObjectList(key: _DigitalFormLocalDSKeys.testString, value: [model1, model2]);
      final value = prefsManager.getObjectList<_BaseModel>(key: _DigitalFormLocalDSKeys.testString, model: const _BaseModel());
      expect(value, [model1, model2]);
    });

    test('Test remove method', () async {
      await prefsManager.setInt(key: _DigitalFormLocalDSKeys.testInt, value: 1);
      await prefsManager.remove(key: _DigitalFormLocalDSKeys.testInt);
      final value = prefsManager.getInt(key: _DigitalFormLocalDSKeys.testInt);
      expect(value, isNull);
    });

    test('Test clear method', () async {
      await prefsManager.setInt(key: _DigitalFormLocalDSKeys.testInt, value: 1);
      await prefsManager.setBool(key: _DigitalFormLocalDSKeys.testBool, value: false);
      await prefsManager.setString(key: _DigitalFormLocalDSKeys.testString, value: 'test');
      await prefsManager.setDouble(key: _DigitalFormLocalDSKeys.testDouble, value: 1.5);
      await prefsManager.clear();
      final value = prefsManager.getInt(key: _DigitalFormLocalDSKeys.testInt);
      expect(value, isNull);
    });

    test('Test containsKey method', () async {
      await prefsManager.setInt(key: _DigitalFormLocalDSKeys.testInt, value: 1);
      final containsKey = prefsManager.containsKey(key: _DigitalFormLocalDSKeys.testInt);
      expect(containsKey, true);
    });
  });
}

class _CoreSharedPreferencesManager extends CoreSharedPreferencesManager {
  _CoreSharedPreferencesManager({
    super.encryptionKey,
    super.encryptionIv,
  });
}

enum _DigitalFormLocalDSKeys implements BaseSharedPrefKeys {
  testInt,
  testDouble,
  testString,
  testBool,
  ;

  const _DigitalFormLocalDSKeys();

  @override
  final bool encrypt = false;

  @override
  String get keyName => name;
}

@immutable
class _BaseModel extends BaseModel<_BaseModel> {
  const _BaseModel({
    this.stringValue = 'testStringValue',
    this.intValue = 1,
    this.doubleValue = 1.5,
    this.boolValue = true,
  });
  final String? stringValue;
  final int? intValue;
  final double? doubleValue;
  final bool? boolValue;

  @override
  Map<String, dynamic> toJson() {
    return {
      'stringValue': stringValue,
      'intValue': intValue,
      'doubleValue': doubleValue,
      'boolValue': boolValue,
    };
  }

  @override
  _BaseModel fromJson(Map<String, dynamic> json) {
    return _BaseModel(
      stringValue: json['stringValue'] as String?,
      intValue: json['intValue'] as int?,
      doubleValue: json['doubleValue'] as double?,
      boolValue: json['boolValue'] as bool?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _BaseModel && other.stringValue == stringValue && other.intValue == intValue && other.doubleValue == doubleValue && other.boolValue == boolValue;
  }

  @override
  int get hashCode {
    return stringValue.hashCode ^ intValue.hashCode ^ doubleValue.hashCode ^ boolValue.hashCode;
  }
}
