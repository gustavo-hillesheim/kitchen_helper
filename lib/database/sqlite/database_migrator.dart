import 'package:sqflite/sqflite.dart';

const kInitialDbVersion = 1;
const kClientModuleDbVersion = 2;
const kClientAndOrderIntegrationDbVersion = 3;
const kLatestDbVersion = kClientAndOrderIntegrationDbVersion;

class DatabaseMigrator {
  Future<void> createSchema(Database db) async {
    await _createIngredientTables(db);
    await _createRecipeTables(db);
    await _createClientTables(db);
    await _createOrderTables(db);
  }

  Future<void> migrateTo(Database db, int newVersion,
      {required int from}) async {
    final oldVersion = from;
    if (oldVersion < kClientModuleDbVersion &&
        newVersion >= kClientModuleDbVersion) {
      await _createClientTables(db);
    }
    if (oldVersion < kClientAndOrderIntegrationDbVersion &&
        newVersion >= kClientAndOrderIntegrationDbVersion) {
      await _createNewOrderTableWithClientIdColumns(db);
      await _migrateClientDataFromOrderTableToClientTables(db);
      await _dropOldOrderTable(db);
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
      clientId INTEGER NOT NULL,
      contactId INTEGER,
      addressId INTEGER,
      orderDate INTEGER NOT NULL,
      deliveryDate INTEGER NOT NULL,
      status TEXT NOT NULL,
      FOREIGN KEY (clientId) REFERENCES clients (id),
      FOREIGN KEY (contactId) REFERENCES clientContacts (id),
      FOREIGN KEY (addressId) REFERENCES clientAddresses (id)
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

  Future<void> _createNewOrderTableWithClientIdColumns(Database db) async {
    await db.execute('PRAGMA foreign_keys=off');
    await db.execute('ALTER TABLE orders RENAME TO _old_orders');
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      clientId INTEGER NOT NULL,
      contactId INTEGER,
      addressId INTEGER,
      orderDate INTEGER NOT NULL,
      deliveryDate INTEGER NOT NULL,
      status TEXT NOT NULL,
      FOREIGN KEY (clientId) REFERENCES clients (id),
      FOREIGN KEY (contactId) REFERENCES clientContacts (id),
      FOREIGN KEY (addressId) REFERENCES clientAddresses (id)
    )''');
    await db.execute('PRAGMA foreign_keys=on');
  }

  Future<void> _dropOldOrderTable(Database db) async {
    await db.execute('DROP TABLE _old_orders');
  }

  Future<void> _migrateClientDataFromOrderTableToClientTables(
      Database db) async {
    final orders = await db.query(
      '_old_orders',
      columns: [
        'id',
        'clientName',
        'clientAddress',
        'orderDate',
        'deliveryDate',
        'status'
      ],
    );
    await db.transaction((txn) async {
      for (final order in orders) {
        final clientId = await _getClientIdOrInsert(txn, order);
        final addressId = await _getAddressIdOrInsert(txn, order, clientId);
        await txn.insert(
          'orders',
          {
            'id': order['id'],
            'clientId': clientId,
            'addressId': addressId,
            'orderDate': order['orderDate'],
            'deliveryDate': order['deliveryDate'],
            'status': order['status'],
          },
        );
      }
    });
  }

  Future<int> _getClientIdOrInsert(
      DatabaseExecutor db, Map<String, dynamic> client) async {
    final clientName = client['clientName'];
    final clientData = await db.query(
      'clients',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [clientName],
    );
    if (clientData.isNotEmpty) {
      return clientData.first['id'] as int;
    } else {
      return await db.insert('clients', {'name': clientName});
    }
  }

  Future<int> _getAddressIdOrInsert(
      DatabaseExecutor db, Map<String, dynamic> client, int clientId) async {
    final addresses = await db.query(
      'clientAddresses',
      columns: ['id'],
      where: 'identifier = ? AND clientId = ?',
      whereArgs: [client['clientAddress'], clientId],
    );
    if (addresses.isNotEmpty) {
      return addresses.first['id'] as int;
    } else {
      return await db.insert(
        'clientAddresses',
        {'identifier': client['clientAddress'], 'clientId': clientId},
      );
    }
  }
}
