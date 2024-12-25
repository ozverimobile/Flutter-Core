import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'models/todo_model.dart';
import 'sqflite_manager.dart';
import 'tables.dart';

void main() {
  late SqfliteManager sqfliteManager;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    sqfliteManager = SqfliteManager();
  });

  group('Sqflite Manager Test', () {
    test('Testing BaseResult', () async {
      await sqfliteManager.openDB();
      final result = await sqfliteManager.execute('''
      INSERT INTOO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
      VALUES ('Alışveriş Yap', 'Market alışverişi yapılacak', 0);
      ''');

      expect(result.error, isNotNull);
      await sqfliteManager.deleteDB();
    });

    test('The firstIntValue function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.execute('''
      INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
      VALUES ('Alışveriş Yap', 'Market alışverişi yapılacak', 0);
      ''');

      final result = await sqfliteManager.rawQuery('select count(*) from ${TodoTable.tableName}');
      final firstIntValue = sqfliteManager.firstIntValue(result.data!);
      expect(firstIntValue, 1);
      await sqfliteManager.deleteDB();
    });

    test('The execute function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.execute('''
      INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
      VALUES ('Alışveriş Yap', 'Market alışverişi yapılacak', 0);
      ''');

      final result = await sqfliteManager.querySerializable(TodoTable.tableName, const TodoModel());
      expect(result.data?.length, 1);
      expect(result.data?.firstOrNull?.id, 1);
      expect(result.data?.firstOrNull?.title, 'Alışveriş Yap');
      expect(result.data?.firstOrNull?.description, 'Market alışverişi yapılacak');
      expect(result.data?.firstOrNull?.isDone, 0);
      await sqfliteManager.deleteDB();
    });

    test('The rawQuery function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      final result = await sqfliteManager.rawQuery('SELECT * FROM ${TodoTable.tableName} where ${TodoTable.id} = ?', [1]);
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull![TodoTable.id], 1);
      expect(result.data!.firstOrNull![TodoTable.title], 'Alışveriş Yap');
      expect(result.data!.firstOrNull![TodoTable.description], 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull![TodoTable.isDone], 0);
      await sqfliteManager.deleteDB();
    });

    test('The rawQuerySerializable function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      final result = await sqfliteManager.rawQuerySerializable(
        'SELECT * FROM ${TodoTable.tableName} where ${TodoTable.id} = ?',
        const TodoModel(),
        [1],
      );
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull!.id, 1);
      expect(result.data!.firstOrNull!.title, 'Alışveriş Yap');
      expect(result.data!.firstOrNull!.description, 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull!.isDone, 0);
      await sqfliteManager.deleteDB();
    });

    test('The query function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      final result = await sqfliteManager.query(
        TodoTable.tableName,
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull![TodoTable.id], 1);
      expect(result.data!.firstOrNull![TodoTable.title], 'Alışveriş Yap');
      expect(result.data!.firstOrNull![TodoTable.description], 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull![TodoTable.isDone], 0);
      await sqfliteManager.deleteDB();
    });

    test('The querySerializable function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      final result = await sqfliteManager.querySerializable(
        TodoTable.tableName,
        const TodoModel(),
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull!.id, 1);
      expect(result.data!.firstOrNull!.title, 'Alışveriş Yap');
      expect(result.data!.firstOrNull!.description, 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull!.isDone, 0);
      await sqfliteManager.deleteDB();
    });

    test('The rawInsert function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.rawInsert('''
        INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
        VALUES ('Alışveriş Yap', 'Market alışverişi yapılacak', 0);
    ''');

      final result = await sqfliteManager.querySerializable(
        TodoTable.tableName,
        const TodoModel(),
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull!.id, 1);
      expect(result.data!.firstOrNull!.title, 'Alışveriş Yap');
      expect(result.data!.firstOrNull!.description, 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull!.isDone, 0);
      await sqfliteManager.deleteDB();
    });

    test('The insert function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      final result = await sqfliteManager.querySerializable(
        TodoTable.tableName,
        const TodoModel(),
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull!.id, 1);
      expect(result.data!.firstOrNull!.title, 'Alışveriş Yap');
      expect(result.data!.firstOrNull!.description, 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull!.isDone, 0);
      await sqfliteManager.deleteDB();
    });

    test('The rawUpdate function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      await sqfliteManager.rawUpdate('''
        UPDATE ${TodoTable.tableName}
        SET ${TodoTable.isDone} = 1
        WHERE ${TodoTable.id} = 1;
      ''');

      final result = await sqfliteManager.querySerializable(
        TodoTable.tableName,
        const TodoModel(),
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull!.id, 1);
      expect(result.data!.firstOrNull!.title, 'Alışveriş Yap');
      expect(result.data!.firstOrNull!.description, 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull!.isDone, 1);
      await sqfliteManager.deleteDB();
    });

    test('The update function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      await sqfliteManager.update(
        TodoTable.tableName,
        {
          TodoTable.isDone: 1,
        },
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );

      final result = await sqfliteManager.querySerializable(
        TodoTable.tableName,
        const TodoModel(),
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );
      expect(result.data?.length, 1);
      expect(result.data!.firstOrNull!.id, 1);
      expect(result.data!.firstOrNull!.title, 'Alışveriş Yap');
      expect(result.data!.firstOrNull!.description, 'Market alışverişi yapılacak');
      expect(result.data!.firstOrNull!.isDone, 1);
      await sqfliteManager.deleteDB();
    });

    test('The rawDelete function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      final result = await sqfliteManager.rawDelete('''
        DELETE FROM ${TodoTable.tableName}
        WHERE ${TodoTable.id} = 1;
      ''');

      expect(result.data, 1);
      await sqfliteManager.deleteDB();
    });

    test('The delete function is being tested.', () async {
      await sqfliteManager.openDB();
      await sqfliteManager.insert(TodoTable.tableName, {
        TodoTable.title: 'Alışveriş Yap',
        TodoTable.description: 'Market alışverişi yapılacak',
        TodoTable.isDone: 0,
      });

      final result = await sqfliteManager.delete(
        TodoTable.tableName,
        where: '${TodoTable.id} = ?',
        whereArgs: [1],
      );

      expect(result.data, 1);
      await sqfliteManager.deleteDB();
    });

    test('The transaction function is being tested.', () async {
      await sqfliteManager.openDB();
      final transactionResult = await sqfliteManager.transaction((txn) async {
        final insertResult = await txn.insert(TodoTable.tableName, {
          TodoTable.title: 'title',
          TodoTable.description: 'description',
          TodoTable.isDone: 0,
        });

        final rawInsertResult = await txn.rawInsert('''
          INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
          VALUES ('title2', 'description2', 0);
        ''');

        final updateResult = await txn.update(
          TodoTable.tableName,
          {
            TodoTable.isDone: 1,
          },
          where: '${TodoTable.id} = ?',
          whereArgs: [1],
        );

        final rawUpdateResult = await txn.rawUpdate('''
          UPDATE ${TodoTable.tableName}
          SET ${TodoTable.isDone} = 1
          WHERE ${TodoTable.id} = 2;
        ''');

        final queryResult = await txn.query(TodoTable.tableName, where: '${TodoTable.id} = ?', whereArgs: [1]);

        final rawQueryResult = await txn.rawQuery('SELECT * FROM ${TodoTable.tableName} where ${TodoTable.id} = ?', [2]);

        final deleteResult = await txn.delete(TodoTable.tableName, where: '${TodoTable.id} = ?', whereArgs: [1]);

        final rawDeleteResult = await txn.rawDelete('DELETE FROM ${TodoTable.tableName} WHERE ${TodoTable.id} = 2;');

        return [insertResult, rawInsertResult, updateResult, rawUpdateResult, queryResult, rawQueryResult, deleteResult, rawDeleteResult];
      });

      expect(transactionResult.data![0], 1);
      expect(transactionResult.data![1], 2);
      expect(transactionResult.data![2], 1);
      expect(transactionResult.data![3], 1);
      final queryResult = transactionResult.data![4] as List<Map<String, Object?>>;
      expect(queryResult.length, 1);
      expect(queryResult.firstOrNull![TodoTable.id], 1);
      expect(queryResult.firstOrNull![TodoTable.title], 'title');
      expect(queryResult.firstOrNull![TodoTable.description], 'description');
      expect(queryResult.firstOrNull![TodoTable.isDone], 1);
      final rawQueryResult = transactionResult.data![5] as List<Map<String, Object?>>;
      expect(rawQueryResult.length, 1);
      expect(rawQueryResult.firstOrNull![TodoTable.id], 2);
      expect(rawQueryResult.firstOrNull![TodoTable.title], 'title2');
      expect(rawQueryResult.firstOrNull![TodoTable.description], 'description2');
      expect(rawQueryResult.firstOrNull![TodoTable.isDone], 1);
      expect(transactionResult.data![6], 1);
      expect(transactionResult.data![7], 1);
      await sqfliteManager.deleteDB();
    });

    test('The transaction function is being tested (2).', () async {
      await sqfliteManager.openDB();
      final transactionResult = await sqfliteManager.transaction((txn) async {
        final insertResult = await txn.insert(TodoTable.tableName, {
          TodoTable.title: 'title',
          TodoTable.description: 'description',
          TodoTable.isDone: 0,
        });

        final rawInsertResult = await txn.rawInsert('''
          INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
          VALUES ('title2', 'description2', 0);
        ''');

        final updateResult = await txn.update(
          TodoTable.tableName,
          {
            TodoTable.isDone: 1,
          },
          where: '${TodoTable.id} = ?',
          whereArgs: [1],
        );

        final rawUpdateResult = await txn.rawUpdate('''
          UPDATEEEEEEE ${TodoTable.tableName}
          SET ${TodoTable.isDone} = 1
          WHERE ${TodoTable.id} = 2;
        ''');

        final queryResult = await txn.query(TodoTable.tableName, where: '${TodoTable.id} = ?', whereArgs: [1]);

        final rawQueryResult = await txn.rawQuery('SELECT * FROM ${TodoTable.tableName} where ${TodoTable.id} = ?', [2]);

        return [insertResult, rawInsertResult, updateResult, rawUpdateResult, queryResult, rawQueryResult];
      });

      expect(transactionResult.error, isNotNull);
      expect(transactionResult.data, isNull);

      final todos = await sqfliteManager.querySerializable(TodoTable.tableName, const TodoModel());
      expect(todos.data?.length, 0);
      await sqfliteManager.deleteDB();
    });

    test('The batch function is being tested.', () async {
      await sqfliteManager.openDB();

      final batch = await sqfliteManager.batch();

      batch
        ..execute('''
        INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
        VALUES ('title', 'description', 0);
      ''')
        ..rawInsert('''
        INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
        VALUES ('title2', 'description2', 0);
      ''')
        ..insert(TodoTable.tableName, {
          TodoTable.title: 'title3',
          TodoTable.description: 'description3',
          TodoTable.isDone: 0,
        })
        ..rawUpdate('''
        UPDATE ${TodoTable.tableName}
        SET ${TodoTable.isDone} = 1
        WHERE ${TodoTable.id} = 1;
      ''')
        ..update(
          TodoTable.tableName,
          {
            TodoTable.isDone: 1,
          },
          where: '${TodoTable.id} = ?',
          whereArgs: [2],
        )
        ..query(TodoTable.tableName)
        ..rawQuery('SELECT * FROM ${TodoTable.tableName}')
        ..delete(TodoTable.tableName, where: '${TodoTable.id} = ?', whereArgs: [1])
        ..rawDelete('DELETE FROM ${TodoTable.tableName}');

      final result = await batch.commit();

      expect(result.data![0], isNull);
      expect(result.data![1], 2);
      expect(result.data![2], 3);
      expect(result.data![3], 1);
      expect(result.data![4], 1);
      final queryResult = result.data![5]! as List<Map<String, Object?>>;
      expect(queryResult.length, 3);
      final rawQueryResult = result.data![6]! as List<Map<String, Object?>>;
      expect(rawQueryResult.length, 3);
      expect(result.data![7], 1);
      expect(result.data![8], 2);

      await sqfliteManager.deleteDB();
    });

    test('The batch function is being tested (2).', () async {
      await sqfliteManager.openDB();

      final batch = await sqfliteManager.batch();

      batch
        ..execute('''
        INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
        VALUES ('title', 'description', 0);
      ''')
        ..rawInsert('''
        INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
        VALUES ('title2', 'description2', 0);
      ''')
        ..insert(TodoTable.tableName, {
          TodoTable.title: 'title3',
          TodoTable.description: 'description3',
          TodoTable.isDone: 0,
        })
        ..rawUpdate('''
        UPDATEEE ${TodoTable.tableName}
        SET ${TodoTable.isDone} = 1
        WHERE ${TodoTable.id} = 1;
      ''')
        ..update(
          TodoTable.tableName,
          {
            TodoTable.isDone: 1,
          },
          where: '${TodoTable.id} = ?',
          whereArgs: [2],
        )
        ..query(TodoTable.tableName)
        ..rawQuery('SELECT * FROM ${TodoTable.tableName}');

      final result = await batch.commit();

      expect(result.data, isNull);
      expect(result.error, isNotNull);

      await sqfliteManager.deleteDB();
    });

    test('The batch function is being tested (3).', () async {
      await sqfliteManager.openDB();

      final batch = await sqfliteManager.batch();

      batch
        ..execute('''
        INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
        VALUES ('title', 'description', 0);
      ''')
        ..rawInsert('''
        INSERT INTO ${TodoTable.tableName} (${TodoTable.title}, ${TodoTable.description}, ${TodoTable.isDone})
        VALUES ('title2', 'description2', 0);
      ''')
        ..insert('TodoTable.tableName', {
          TodoTable.title: 'title3',
          TodoTable.description: 'description3',
          TodoTable.isDone: 0,
        })
        ..rawUpdate('''
        UPDATE ${TodoTable.tableName}
        SET ${TodoTable.isDone} = 1
        WHERE ${TodoTable.id} = 1;
      ''')
        ..update(
          TodoTable.tableName,
          {
            TodoTable.isDone: 1,
          },
          where: '${TodoTable.id} = ?',
          whereArgs: [2],
        )
        ..query(TodoTable.tableName)
        ..rawQuery('SELECT * FROM ${TodoTable.tableName}')
        ..delete(TodoTable.tableName, where: '${TodoTable.id} = ?', whereArgs: [1])
        ..rawDelete('DELETE FROM ${TodoTable.tableName}');

      final result = await batch.commit(continueOnError: true);

      expect(result.data![0], isNull);
      expect(result.data![1], 2);
      expect(result.data![2], isA<DatabaseException>());
      expect(result.data![3], 1);
      expect(result.data![4], 1);
      final queryResult = result.data![5]! as List<Map<String, Object?>>;
      expect(queryResult.length, 2);
      final rawQueryResult = result.data![6]! as List<Map<String, Object?>>;
      expect(rawQueryResult.length, 2);
      expect(result.data![7], 1);
      expect(result.data![8], 1);

      await sqfliteManager.deleteDB();
    });
  });
}
