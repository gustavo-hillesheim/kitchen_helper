import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';

typedef TransactionCallback<T> = FutureOr<T> Function();

class SQLiteDatabase {
  static SQLiteDatabase? _instance;
  static const _databaseName = 'KitchenHelper.db';
  static const _databaseVersion = 1;

  final Database _database;
  DatabaseExecutor _executor;

  SQLiteDatabase(this._database) : _executor = _database;

  static Future<SQLiteDatabase> getInstance() async {
    _instance ??= SQLiteDatabase(await _initDatabase());
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
      cost REAL NOT NULL
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
      type TEXT NOT NULL,
      quantity REAL NOT NULL
    )''');
  }

  Future<T> insideTransaction<T>(TransactionCallback<T> action) async {
    return await _database.transaction((txn) async {
      _executor = txn;
      final result = await action();
      _executor = _database;
      // We need to throw an exception in order to rollback the transaction
      // but the result must be returned to the caller nevertheless
      if (result is Either &&
          result.isLeft() &&
          result.getLeft().toNullable() is Failure) {
        throw _TransactionException(result);
      }
      return result;
    }).catchError((error) {
      // Returns the result of the action as though nothing happened
      if (error is _TransactionException) {
        return error.either as T;
      }
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
    final whereObj = _Where.fromMap(where ?? {});
    return _executor.query(
      table,
      columns: columns,
      where: whereObj.where,
      whereArgs: whereObj.whereArgs,
    );
  }

  Future<void> delete({
    required String table,
    required Map<String, dynamic> where,
  }) {
    final whereObj = _Where.fromMap(where);
    return _executor.delete(
      table,
      where: whereObj.where,
      whereArgs: whereObj.whereArgs,
    );
  }
}

class _Where {
  final String? where;
  final List<dynamic>? whereArgs;

  _Where(this.where, this.whereArgs);

  factory _Where.fromMap(Map<String, dynamic> map) {
    var whereStr = '';
    final whereArgs = [];
    map.forEach((key, value) {
      if (whereStr.isNotEmpty) {
        whereStr += ' AND ';
      }
      whereStr += '$key = ?';
      whereArgs.add(value);
    });
    return _Where(
      whereStr.isEmpty ? null : whereStr,
      whereStr.isEmpty ? null : whereArgs,
    );
  }
}

class _TransactionException<T> implements Exception {
  final Either either;

  _TransactionException(this.either);
}