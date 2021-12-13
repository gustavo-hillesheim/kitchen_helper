import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class SQLiteDatabase {
  static SQLiteDatabase? _instance;
  static const _databaseName = 'KitchenHelper.db';
  static const _databaseVersion = 1;
  static final lock = Lock();

  final Database database;

  SQLiteDatabase._(this.database);

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

  Future<int> insert(String table, Map<String, dynamic> data) async {
    return database.insert(table, data);
  }

  Future<void> update(
      String table, Map<String, dynamic> data, String idColumn, int id) async {
    await database.update(
      table,
      data,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteById(String table, String idColumn, int id) async {
    await database.delete(table, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> findAll(String table) async {
    return await database.query(table);
  }

  Future<Map<String, dynamic>?> findById(
      String table, String idColumn, int id) async {
    final rows =
        await database.query(table, where: '$idColumn = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      return rows[0];
    }
    return null;
  }

  Future<bool> exists(String table, String idColumn, int id) async {
    final rows = await database
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
    return database.query(table,
        columns: columns, where: whereStr, whereArgs: whereArgs);
  }
}
