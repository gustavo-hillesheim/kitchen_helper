import 'package:sqflite/sqflite.dart';

const kInitialDatabaseVersion = 1;
const kClientModuleDatabaseVersion = 2;

class DatabaseMigrator {
  Future<void> createSchema(Database db) async {
    await _createIngredientTables(db);
    await _createRecipeTables(db);
    await _createOrderTables(db);
    await _createClientTables(db);
  }

  Future<void> migrateTo(Database db, int newVersion,
      {required int from}) async {
    final oldVersion = from;
    if (oldVersion < kClientModuleDatabaseVersion &&
        newVersion >= kClientModuleDatabaseVersion) {
      await _createClientTables(db);
    }
  }

  Future<void> _createIngredientTables(Database db) async {
    await db.execute('''
    CREATE TABLE ingredients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      quantity REAL NOT NULL,
      measurementUnit TEXT NOT NULL,
      cost REAL NOT NULL
    )''');
  }

  Future<void> _createRecipeTables(Database db) async {
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

  Future<void> _createOrderTables(Database db) async {
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

  Future<void> _createClientTables(Database db) async {
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
}
