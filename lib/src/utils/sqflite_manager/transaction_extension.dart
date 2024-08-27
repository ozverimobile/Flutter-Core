import 'package:flutter_core/flutter_core.dart';
import 'package:sqflite/sqlite_api.dart';

extension TransactionExtension on Transaction {
  Future<List<T>> rawQuerySerializable<T extends BaseModel<dynamic>>(
    String sql,
    T parseModel, [
    List<Object?>? arguments,
  ]) async {
    final result = await rawQuery(sql, arguments);
    return result.map((e) => parseModel.fromJson(e) as T).toList();
  }

  Future<List<T>> querySerializable<T extends BaseModel<dynamic>>(
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
    final result = await query(
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
    return result.map((e) => parseModel.fromJson(e) as T).toList();
  }
}
