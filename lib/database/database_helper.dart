import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      'family_finance.db',
    );

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enables SQLite ON DELETE CASCADE enforcement
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customer_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        credit REAL DEFAULT 0,
        debit REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE weeks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE week_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weekId INTEGER,
        description TEXT,
        credit REAL DEFAULT 0,
        debit REAL DEFAULT 0,
        FOREIGN KEY (weekId) REFERENCES weeks (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_week_entries_weekId ON week_entries(weekId)',
    );
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE customers ADD COLUMN address TEXT',
      );
      await db.execute(
        'ALTER TABLE customers ADD COLUMN notes TEXT',
      );
    }
    if (oldVersion < 3) {
      // Re-create week_entries if needed to enforce foreign key constraint or add index
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_week_entries_weekId ON week_entries(weekId)',
      );
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}