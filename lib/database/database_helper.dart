import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('believe_pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 10,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // =========================
    // PRODUCTS
    // =========================
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        barcode TEXT NOT NULL,
        supplierId INTEGER,
        costPrice REAL NOT NULL DEFAULT 0
      )
    ''');

    // =========================
    // SALES
    // =========================
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        saleDate TEXT NOT NULL
      )
    ''');

    // =========================
    // SALE ITEMS
    // =========================
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales(id),
        FOREIGN KEY (productId) REFERENCES products(id)
      )
    ''');

    // =========================
    // CUSTOMERS
    // =========================
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL
      )
    ''');

    // =========================
    // SUPPLIERS
    // =========================
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL
      )
    ''');

    // =========================
    // STOCK RECEIPTS
    // =========================
    await db.execute('''
      CREATE TABLE stock_receipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        supplierId INTEGER,
        quantity INTEGER NOT NULL,
        costPrice REAL NOT NULL,
        receiptDate TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES products(id),
        FOREIGN KEY (supplierId) REFERENCES suppliers(id)
      )
    ''');

    // =========================
    // STOCK MOVEMENTS
    // =========================
    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        movementType TEXT NOT NULL,
        referenceId INTEGER,
        note TEXT,
        movementDate TEXT NOT NULL,
        stockBefore INTEGER NOT NULL DEFAULT 0,
        stockAfter INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (productId) REFERENCES products(id)
      )
    ''');

    // =========================
    // EXPENSES
    // =========================
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        expenseDate TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // =========================
    // VERSION 2
    // BARCODE
    // =========================
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE products
        ADD COLUMN barcode TEXT NOT NULL DEFAULT ''
      ''');
    }

    // =========================
    // VERSION 3
    // CUSTOMERS
    // =========================
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT NOT NULL,
          address TEXT NOT NULL
        )
      ''');
    }

    // =========================
    // VERSION 4
    // SUPPLIERS
    // =========================
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS suppliers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT NOT NULL,
          address TEXT NOT NULL
        )
      ''');
    }

    // =========================
    // VERSION 5
    // SUPPLIER + COST PRICE
    // =========================
    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE products
        ADD COLUMN supplierId INTEGER
      ''');

      await db.execute('''
        ALTER TABLE products
        ADD COLUMN costPrice REAL NOT NULL DEFAULT 0
      ''');
    }

    // =========================
    // VERSION 6
    // STOCK RECEIPTS
    // =========================
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_receipts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          supplierId INTEGER,
          quantity INTEGER NOT NULL,
          costPrice REAL NOT NULL,
          receiptDate TEXT NOT NULL,
          FOREIGN KEY (productId) REFERENCES products(id),
          FOREIGN KEY (supplierId) REFERENCES suppliers(id)
        )
      ''');
    }

    // =========================
    // VERSION 7
    // STOCK RECEIPTS SAFETY CHECK
    // =========================
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_receipts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          supplierId INTEGER,
          quantity INTEGER NOT NULL,
          costPrice REAL NOT NULL,
          receiptDate TEXT NOT NULL,
          FOREIGN KEY (productId) REFERENCES products(id),
          FOREIGN KEY (supplierId) REFERENCES suppliers(id)
        )
      ''');
    }

    // =========================
    // VERSION 8
    // STOCK MOVEMENTS
    // =========================
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_movements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          movementType TEXT NOT NULL,
          referenceId INTEGER,
          note TEXT,
          movementDate TEXT NOT NULL,
          FOREIGN KEY (productId) REFERENCES products(id)
        )
      ''');
    }

    // =========================
    // VERSION 9
    // STOCK BEFORE / STOCK AFTER
    // =========================
    if (oldVersion < 9) {
      await db.execute('''
        ALTER TABLE stock_movements
        ADD COLUMN stockBefore INTEGER NOT NULL DEFAULT 0
      ''');

      await db.execute('''
        ALTER TABLE stock_movements
        ADD COLUMN stockAfter INTEGER NOT NULL DEFAULT 0
      ''');
    }

    // =========================
    // VERSION 10
    // EXPENSES
    // =========================
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          note TEXT,
          expenseDate TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = await instance.database;

    await db.close();

    _database = null;
  }
}
