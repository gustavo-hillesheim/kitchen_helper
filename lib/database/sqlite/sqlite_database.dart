import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'where.dart';
import 'database_migrator.dart';
import '../../core/core.dart';

typedef TransactionCallback<T> = FutureOr<T> Function();

class SQLiteDatabase {
  static SQLiteDatabase? _instance;
  static const _databaseName = 'KitchenHelper.db';
  static const _databaseVersion = kLatestDbVersion;

  final Database _database;
  DatabaseExecutor _executor;

  SQLiteDatabase(this._database) : _executor = _database;

  static Future<SQLiteDatabase> getInstance() async {
    _instance ??= SQLiteDatabase(await _initDatabase());
    return _instance!;
  }

  static Future<Database> _initDatabase() async {
    // Used for testing only
    if (Platform.isWindows) {
      return databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    if (kDebugMode) {
      Sqflite.setDebugModeOn(true);
    }
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future _onCreate(Database db, int version) async {
    await DatabaseMigrator().createSchema(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await DatabaseMigrator().migrateTo(db, newVersion, from: oldVersion);
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

  Future<List<Map<String, dynamic>>> findAll(
    String table, {
    Map<String, dynamic>? where,
  }) async {
    final whereObj = Where.fromMap(where ?? {});
    return await _executor.query(
      table,
      where: whereObj.where,
      whereArgs: whereObj.whereArgs,
    );
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
      Map<String, dynamic>? where,
      String? orderBy}) {
    final whereObj = Where.fromMap(where ?? {});
    return _executor.query(
      table,
      columns: columns,
      where: whereObj.where,
      whereArgs: whereObj.whereArgs,
      orderBy: orderBy,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(String query, [List? arguments]) {
    return _executor.rawQuery(query, arguments);
  }

  Future<void> delete({
    required String table,
    required Map<String, dynamic> where,
  }) {
    final whereObj = Where.fromMap(where);
    return _executor.delete(
      table,
      where: whereObj.where,
      whereArgs: whereObj.whereArgs,
    );
  }
}

class _TransactionException<T> implements Exception {
  final Either either;

  _TransactionException(this.either);
}
