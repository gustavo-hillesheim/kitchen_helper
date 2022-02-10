import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/core.dart';

const kInitialDatabaseVersion = 1;
const kClientModuleDatabaseVersion = 2;
typedef TransactionCallback<T> = FutureOr<T> Function();

class SQLiteDatabase {
  static SQLiteDatabase? _instance;
  static const _databaseName = 'KitchenHelper.db';
  static const _databaseVersion = kClientModuleDatabaseVersion;

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
        ),
      );
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    Sqflite.setDebugModeOn(true);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future _onCreate(Database db, int version) async {
    await _createIngredientTables(db);
    await _createRecipeTables(db);
    await _createOrderTables(db);
    await _createClientTables(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < kClientModuleDatabaseVersion &&
        newVersion >= kClientModuleDatabaseVersion) {
      await _createClientTables(db);
    }
  }

  static Future<void> _createIngredientTables(Database db) async {
    await db.execute('''
    CREATE TABLE ingredients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      quantity REAL NOT NULL,
      measurementUnit TEXT NOT NULL,
      cost REAL NOT NULL
    )''');
  }

  static Future<void> _createRecipeTables(Database db) async {
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
      quantity REAL NOT NULL,
      FOREIGN KEY (parentRecipeId) REFERENCES recipe (id) ON DELETE CASCADE
    )''');
  }

  static Future<void> _createOrderTables(Database db) async {
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      clientName TEXT NOT NULL,
      clientAddress TEXT NOT NULL,
      orderDate INTEGER NOT NULL,
      deliveryDate INTEGER NOT NULL,
      status TEXT NOT NULL
    )''');
    await db.execute('''
    CREATE TABLE orderProducts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER NOT NULL,
      productId INTEGER NOT NULL,
      quantity REAL NOT NULL,
      FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE,
      FOREIGN KEY (productId) REFERENCES recipes (id) ON DELETE CASCADE
    )''');
    await db.execute('''
    CREATE TABLE orderDiscounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER NOT NULL,
      reason TEXT NOT NULL,
      type TEXT NOT NULL,
      value REAL NOT NULL,
      FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
    )''');
  }

  static Future<void> _createClientTables(Database db) async {
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
      ''');
    await db.execute('''
      CREATE TABLE clientContacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact TEXT NOT NULL,
        clientId INTEGER NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE
      )
      ''');
    await db.execute('''
      CREATE TABLE clientAddresses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        identifier TEXT NOT NULL,
        cep INTEGER,
        street TEXT,
        number INTEGER,
        complement TEXT,
        neighborhood TEXT,
        city TEXT,
        state TEXT,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE
      )
      ''');
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
    final whereObj = _Where.fromMap(where ?? {});
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
    final whereObj = _Where.fromMap(where ?? {});
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
