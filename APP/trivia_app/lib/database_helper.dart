import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trivia_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Session Table for local token storage
    await db.execute('''
    CREATE TABLE session (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      token TEXT NOT NULL,
      usuario_email TEXT NOT NULL,
      perfil TEXT NOT NULL
    )
    ''');

    // Local active questions cache (to prevent leaving and losing progress)
    await db.execute('''
    CREATE TABLE active_quiz (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bank_id INTEGER NOT NULL,
      current_score INTEGER NOT NULL DEFAULT 0,
      is_finished INTEGER NOT NULL DEFAULT 0
    )
    ''');
  }

  Future<void> saveSession(String token, String email, String perfil) async {
    final db = await instance.database;
    await db.delete('session'); // Clear old session
    await db.insert('session', {
      'token': token,
      'usuario_email': email,
      'perfil': perfil
    });
  }

  Future<Map<String, dynamic>?> getSession() async {
    final db = await instance.database;
    final result = await db.query('session', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> clearAllData() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trivia_local.db');
    
    // Si el token expira o la sesion se cierra, recreamos la db limpia
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Delete the entire DB file
    File dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }

  Future<void> saveActiveQuiz(int bankId, int currentScore) async {
    final db = await instance.database;
    await db.delete('active_quiz');
    await db.insert('active_quiz', {
      'bank_id': bankId,
      'current_score': currentScore,
      'is_finished': 0
    });
  }
}
