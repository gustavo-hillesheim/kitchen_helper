import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class SQLiteDatabase {
  static SQLiteDatabase? instance;
  static const _databaseName = 'KitchenHelper.db';
  static const _databaseVersion = 1;
  static final lock = Lock();

  final Database database;

  SQLiteDatabase._(this.database);

  Future<SQLiteDatabase> getInstance() async {
    instance ??= SQLiteDatabase._(await _initDatabase());
    return instance!;
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
      id TEXT PRIMARY KEY,
      name TEXT,
      quantity REAL,
      measurementUnit TEXT,
      price REAL
    ''');
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

  Future<List<T>> findAll<T>(
      String table, T Function(Map<String, dynamic>) fromMap) async {
    final rows = await database.query(table);
    return rows.map(fromMap).toList(growable: false);
  }

  Future<T?> findById<T>(String table, String idColumn, int id,
      T Function(Map<String, dynamic>) fromMap) async {
    final rows =
        await database.query(table, where: '$idColumn = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      return fromMap(rows[0]);
    }
    return null;
  }
}
