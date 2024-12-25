import 'tables.dart';

class SqlQueries {
  static String createTodos = '''
      CREATE TABLE ${TodoTable.tableName} (
      ${TodoTable.id} INTEGER, 
      ${TodoTable.title} TEXT,
      ${TodoTable.description} TEXT,
      ${TodoTable.isDone} INTEGER,
      PRIMARY KEY("${TodoTable.id}" AUTOINCREMENT)
    );
  ''';
}
