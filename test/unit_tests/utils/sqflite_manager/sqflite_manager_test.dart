import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'sqflite_manager.dart';
import 'tables.dart';

void main() {
  SqfliteManager sqfliteManager;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    sqfliteManager = SqfliteManager();
    await sqfliteManager.openDB();
  });

  group('Sqflite Manager Test', () {
    test('Test 1', () async {
      final result = await sqfliteManager.rawQuery('SELECT * FROM ${ServiceCacheTable.tableName}');

      expect(1, 1);
    });
  });
}
