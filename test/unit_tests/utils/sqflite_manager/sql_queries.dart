

import 'tables.dart';

class SqlQueries {
  static String createServiceCaches = '''
      CREATE TABLE ${ServiceCacheTable.tableName} (
      ${ServiceCacheTable.id} INTEGER, 
      ${ServiceCacheTable.userId} TEXT,
      ${ServiceCacheTable.path} TEXT,
      ${ServiceCacheTable.httpType} TEXT,
      ${ServiceCacheTable.queryParameters} TEXT,
      ${ServiceCacheTable.pathSuffix} TEXT,
      ${ServiceCacheTable.requestData} TEXT,
      ${ServiceCacheTable.baseResponse} TEXT,
      PRIMARY KEY("${ServiceCacheTable.id}" AUTOINCREMENT)
    );
  ''';
}
