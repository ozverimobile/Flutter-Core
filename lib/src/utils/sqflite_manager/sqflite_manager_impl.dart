import 'dart:io';

import 'package:flutter_core/flutter_core.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class ICoreSqfliteManager {
  Future<void> openDB();

  int? firstIntValue(List<Map<String, Object?>> list);

  Future<BaseResult<void>> execute(String sql, [List<Object?>? arguments]);

  Future<BaseResult<List<Map<String, Object?>>>> rawQuery(String sql, [List<Object?>? arguments]);

  Future<BaseResult<List<T>>> rawQuerySerializable<T extends BaseModel<dynamic>>(String sql, T parseModel, [List<Object?>? arguments]);

  Future<BaseResult<List<Map<String, Object?>>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset});

  Future<BaseResult<List<T>>> querySerializable<T extends BaseModel<dynamic>>(String table, T parseModel, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset});

  Future<BaseResult<int>> rawInsert(String sql, [List<Object?>? arguments]);

  Future<BaseResult<int>> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm});

  Future<BaseResult<int>> rawUpdate(String sql, [List<Object?>? arguments]);

  Future<BaseResult<int>> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm});

  Future<BaseResult<int>> rawDelete(String sql, [List<Object?>? arguments]);

  Future<BaseResult<int>> delete(String table, {String? where, List<Object?>? whereArgs});

  Future<BaseResult<T>> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive});

  Future<CoreBatch> batch();

  Future<BaseResult<void>> deleteDB();

  Future<void> onConfigure(Database db);

  Future<void> onCreate(Database db, int version);

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion);

  Future<void> onDowngrade(Database db, int oldVersion, int newVersion);

  Future<void> onOpen(Database db);
}

abstract class CoreSqfliteManager implements ICoreSqfliteManager {
  CoreSqfliteManager({
    required this.version,
    this.path,
    this.readOnly = false,
    this.singleInstance = true,
  });

  final int version;
  final String? path;
  final bool readOnly;
  final bool singleInstance;

  final _databaseName = 'sqliteLocalDb';

  String? _databasePath;

  String? get databasePath => path ?? _databasePath;

  Database? _db;

  @override
  @nonVirtual
  Future<void> openDB() async {
    await _initDB();
  }

  @override
  @nonVirtual
  int? firstIntValue(List<Map<String, Object?>> list) => Sqflite.firstIntValue(list);

  @override
  @nonVirtual
  Future<BaseResult<void>> execute(String sql, [List<Object?>? arguments]) async {
    try {
      final db = await _initDB();
      await db.execute(sql, arguments);
      return BaseResult.success();
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<List<Map<String, Object?>>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      final db = await _initDB();
      final result = await db.rawQuery(sql, arguments);
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<List<T>>> rawQuerySerializable<T extends BaseModel<dynamic>>(
    String sql,
    T parseModel, [
    List<Object?>? arguments,
  ]) async {
    try {
      final db = await _initDB();
      final result = await db.rawQuery(sql, arguments);
      return BaseResult.success(data: result.map((e) => parseModel.fromJson(e) as T).toList());
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<List<Map<String, Object?>>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await _initDB();
      final result = await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<List<T>>> querySerializable<T extends BaseModel<dynamic>>(
    String table,
    T parseModel, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await _initDB();
      final result = await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      return BaseResult.success(data: result.map((e) => parseModel.fromJson(e) as T).toList());
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<int>> rawInsert(String sql, [List<Object?>? arguments]) async {
    try {
      final db = await _initDB();
      final result = await db.rawInsert(sql, arguments);
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<int>> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final db = await _initDB();
      final result = await db.insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<int>> rawUpdate(String sql, [List<Object?>? arguments]) async {
    try {
      final db = await _initDB();
      final result = await db.rawUpdate(sql, arguments);
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<int>> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final db = await _initDB();
      final result = await db.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<int>> rawDelete(String sql, [List<Object?>? arguments]) async {
    try {
      final db = await _initDB();
      final result = await db.rawDelete(sql, arguments);
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<int>> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    try {
      final db = await _initDB();
      final result = await db.delete(table, where: where, whereArgs: whereArgs);
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<BaseResult<T>> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) async {
    try {
      final db = await _initDB();
      final result = await db.transaction(action, exclusive: exclusive);
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  @nonVirtual
  Future<CoreBatch> batch() async {
    final db = await _initDB();
    return CoreBatch(db.batch());
  }

  @override
  @nonVirtual
  Future<BaseResult<void>> deleteDB() async {
    try {
      await deleteDatabase(databasePath!);
      _db = null;
      return BaseResult.success();
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  Future<Database> _initDB() async {
    if (_db?.isOpen ?? false) return _db!;

    if (databasePath == null) {
      final directory = Directory.fromUri(Uri.directory(await getDatabasesPath()));
      _databasePath = '${directory.path}$_databaseName.db';
    }

    _db = await openDatabase(
      databasePath!,
      version: version,
      onConfigure: onConfigure,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      onOpen: onOpen,
      readOnly: readOnly,
      singleInstance: singleInstance,
    );

    return _db!;
  }

  @override
  Future<void> onConfigure(Database db) async {}

  @override
  Future<void> onCreate(Database db, int version);

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion);

  @override
  Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {}

  @override
  Future<void> onOpen(Database db) async {}
}
