import 'tables.dart';

class SqlMigrations {
  static String addIsDoneColumnToTodoTable = '''
    ALTER TABLE ${TodoTable.tableName} ADD COLUMN ${TodoTable.isDone} INTEGER DEFAULT 0;
  ''';
}
