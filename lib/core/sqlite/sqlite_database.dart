import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

typedef TransactionCallback<T> = FutureOr<T> Function();

class SQLiteDatabase {
  static SQLiteDatabase? _instance;
  static const _databaseName = 'KitchenHelper.db';
  static const _databaseVersion = 1;
  static final lock = Lock();

  final Database _database;
  DatabaseExecutor _executor;

  SQLiteDatabase._(this._database) : _executor = _database;

  static Future<SQLiteDatabase> getInstance() async {
    _instance ??= SQLiteDatabase._(await _initDatabase());
    return _instance!;
  }

  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    Sqflite.setDebugModeOn(true);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ingredients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      quantity REAL NOT NULL,
      measurementUnit TEXT NOT NULL,
      price REAL NOT NULL
    )''');
    await db.execute('''
    CREATE TABLE recipes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      notes TEXT,
      quantityProduced REAL NOT NULL,
      quantitySold REAL,
      price REAL,
      canBeSold INTEGER NOT NULL,
      measurementUnit TEXT NOT NULL
    )''');
    await db.execute('''
    CREATE TABLE recipeIngredients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      parentRecipeId INTEGER NOT NULL,
      recipeIngredientId INTEGER NOT NULL,
      type TEXT NOT NULL
    )''');
  }

  Future<T> insideTransaction<T>(TransactionCallback<T> action) async {
    return await _database.transaction((txn) async {
      _executor = txn;
      final result = await action();
      _executor = _database;
      return result;
    });
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    return _executor.insert(table, data);
  }

  Future<void> update(
      String table, Map<String, dynamic> data, String idColumn, int id) async {
    await _executor.update(
      table,
      data,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteById(String table, String idColumn, int id) async {
    await _executor.delete(table, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> findAll(String table) async {
    return await _executor.query(table);
  }

  Future<Map<String, dynamic>?> findById(
      String table, String idColumn, int id) async {
    final rows =
        await _executor.query(table, where: '$idColumn = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      return rows[0];
    }
    return null;
  }

  Future<bool> exists(String table, String idColumn, int id) async {
    final rows = await _executor
        .rawQuery('select 1 from $table where $idColumn = ?', [id]);
    return rows.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> query(
      {required String table,
      required List<String> columns,
      Map<String, dynamic>? where}) {
    var whereStr = '';
    final whereArgs = [];
    where?.forEach((key, value) {
      if (whereStr.isNotEmpty) {
        whereStr += ' AND ';
      }
      whereStr += '$key = ?';
      whereArgs.add(value);
    });
    return _executor.query(table,
        columns: columns, where: whereStr, whereArgs: whereArgs);
  }
}
