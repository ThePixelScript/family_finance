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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
        startDate TEXT,
        endDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE week_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weekId INTEGER,
        description TEXT,
        credit REAL DEFAULT 0,
        debit REAL DEFAULT 0
      )
    ''');
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
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
