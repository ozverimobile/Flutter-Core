import 'package:flutter_core/flutter_core.dart';
import 'package:sqflite/sqlite_api.dart';

abstract interface class ICoreBatch {
  Future<BaseResult<List<Object?>>> commit({bool? exclusive, bool? noResult, bool? continueOnError});
  Future<BaseResult<List<Object?>>> apply({bool? noResult, bool? continueOnError});
  void execute(String sql, [List<Object?>? arguments]);
  void rawInsert(String sql, [List<Object?>? arguments]);
  void insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm});
  void rawUpdate(String sql, [List<Object?>? arguments]);
  void update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm});
  void rawDelete(String sql, [List<Object?>? arguments]);
  void delete(String table, {String? where, List<Object?>? whereArgs});
  void query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset});
  void rawQuery(String sql, [List<Object?>? arguments]);
}

class CoreBatch implements ICoreBatch {
  CoreBatch(this._batch);
  final Batch _batch;

  int get length => _batch.length;

  @override
  Future<BaseResult<List<Object?>>> commit({
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async {
    try {
      final result = await _batch.commit(
        exclusive: exclusive,
        noResult: noResult,
        continueOnError: continueOnError,
      );
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  Future<BaseResult<List<Object?>>> apply({bool? noResult, bool? continueOnError}) async {
    try {
      final result = await _batch.apply(
        noResult: noResult,
        continueOnError: continueOnError,
      );
      return BaseResult.success(data: result);
    } catch (e) {
      return BaseResult.error(error: e);
    }
  }

  @override
  void execute(String sql, [List<Object?>? arguments]) {
    _batch.execute(sql, arguments);
  }

  @override
  void rawInsert(String sql, [List<Object?>? arguments]) {
    _batch.rawInsert(sql, arguments);
  }

  @override
  void insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _batch.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  void rawUpdate(String sql, [List<Object?>? arguments]) {
    _batch.rawUpdate(sql, arguments);
  }

  @override
  void update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _batch.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  void rawDelete(String sql, [List<Object?>? arguments]) {
    _batch.rawDelete(sql, arguments);
  }

  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {
    _batch.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  void query(
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
  }) {
    _batch.query(
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
  }

  @override
  void rawQuery(String sql, [List<Object?>? arguments]) {
    _batch.rawQuery(sql, arguments);
  }
}
