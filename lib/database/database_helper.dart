import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('ration.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ration_cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_number TEXT NOT NULL,
        head_name TEXT NOT NULL,
        relation TEXT,
        mobile TEXT,
        category TEXT,
        units INTEGER,
        rice INTEGER,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_number TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        received INTEGER DEFAULT 1,
        received_date TEXT,

        UNIQUE(card_number, month, year)
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_number TEXT NOT NULL,
        beneficiary_name TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        received_at TEXT NOT NULL,
        operator_name TEXT DEFAULT '',
        remarks TEXT DEFAULT ''
      )
    ''');

    // Performance indices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cards_card_number ON ration_cards(card_number)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_attendance_lookup ON attendance(card_number, month, year)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_history_card ON attendance_history(card_number)',
    );
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          card_number TEXT NOT NULL,
          beneficiary_name TEXT NOT NULL,
          month INTEGER NOT NULL,
          year INTEGER NOT NULL,
          received_at TEXT NOT NULL,
          operator_name TEXT DEFAULT '',
          remarks TEXT DEFAULT ''
        )
      ''');
    }

    if (oldVersion < 7) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_cards_card_number ON ration_cards(card_number)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_attendance_lookup ON attendance(card_number, month, year)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_history_card ON attendance_history(card_number)',
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}