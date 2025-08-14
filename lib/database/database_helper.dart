// database/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../models/report.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static void initialize() {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  String path;
  
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    final documentsPath = await getDatabasesPath();
    path = join(documentsPath, 'imageboard.db');
  } else {
    path = join(await getDatabasesPath(), 'imageboard.db');
  }

  return await openDatabase(
    path,
    version: 3, // Increment version for reports table
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}

  Future<void> _onCreate(Database db, int version) async {
    // Create threads table with INTEGER id (for Unix timestamps)
    await db.execute('''
      CREATE TABLE threads(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imagePath TEXT,
        board TEXT NOT NULL,
        replies INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create posts table with INTEGER id (for Unix timestamps)
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY,
        threadId INTEGER NOT NULL,
        content TEXT NOT NULL,
        imagePath TEXT,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (threadId) REFERENCES threads (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
    CREATE TABLE reports(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      reportType TEXT NOT NULL,
      targetId INTEGER NOT NULL,
      reason TEXT NOT NULL,
      description TEXT,
      createdAt INTEGER NOT NULL,
      status TEXT DEFAULT 'pending'
    )
  ''');

    // Insert some sample data
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 3) {
    // Add reports table for version 3
    await db.execute('''
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reportType TEXT NOT NULL,
        targetId INTEGER NOT NULL,
        reason TEXT NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL,
        status TEXT DEFAULT 'pending'
      )
    ''');
  }
}


  Future<void> _insertSampleData(Database db) async {
    final baseTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    final sampleThreads = [
      {
        'id': baseTime - 3600, // 1 hour ago
        'title': 'Welcome to /g/',
        'content': 'Technology discussion thread\n> be me\n> making imageboard\n> pretty comfy',
        'board': '/g/',
        'replies': 0,
        'createdAt': (baseTime - 3600) * 1000,
      },
      {
        'id': baseTime - 1800, // 30 minutes ago
        'title': 'Random thread',
        'content': '> post anything here\n> **bold text** works\n> *italic* too',
        'board': '/b/',
        'replies': 0,
        'createdAt': (baseTime - 1800) * 1000,
      },
      {
        'id': baseTime - 900, // 15 minutes ago
        'title': 'Video games general',
        'content': 'What are you playing?\n> currently playing retro games\n> nostalgia is real',
        'board': '/v/',
        'replies': 0,
        'createdAt': (baseTime - 900) * 1000,
      },
    ];

    for (var thread in sampleThreads) {
      await db.insert('threads', thread);
    }
  }

  // Generate unique Unix timestamp ID
  int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  // Thread CRUD operations
  Future<int> insertThread(Thread thread) async {
    final db = await database;
    final threadWithId = thread.copyWith(
      id: thread.id ?? _generateUniqueId(),
    );
    await db.insert('threads', threadWithId.toMap());
    return threadWithId.id!;
  }

  Future<List<Thread>> getAllThreads() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'threads',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Thread.fromMap(maps[i]));
  }

  Future<List<Thread>> getThreadsByBoard(String board) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'threads',
      where: 'board = ?',
      whereArgs: [board],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Thread.fromMap(maps[i]));
  }

  Future<Thread?> getThreadById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'threads',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Thread.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateThread(Thread thread) async {
    final db = await database;
    return await db.update(
      'threads',
      thread.toMap(),
      where: 'id = ?',
      whereArgs: [thread.id],
    );
  }

  Future<int> deleteThread(int id) async {
    final db = await database;
    return await db.delete(
      'threads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> incrementThreadReplies(int threadId) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE threads SET replies = replies + 1 WHERE id = ?',
      [threadId],
    );
  }

  // Post CRUD operations
  Future<int> insertPost(Post post) async {
    final db = await database;
    final postWithId = Post(
      id: _generateUniqueId(),
      threadId: post.threadId,
      content: post.content,
      imagePath: post.imagePath,
      createdAt: post.createdAt,
    );
    
    final result = await db.insert('posts', postWithId.toMap());
    await incrementThreadReplies(post.threadId);
    return postWithId.id!;
  }

  Future<List<Post>> getPostsByThread(int threadId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'threadId = ?',
      whereArgs: [threadId],
      orderBy: 'createdAt ASC',
    );
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  Future<int> deletePost(int id) async {
    final db = await database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Thread>> searchThreads(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'threads',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Thread.fromMap(maps[i]));
  }
Future<int> insertReport(Report report) async {
  final db = await database;
  return await db.insert('reports', report.toMap());
}
Future<List<Report>> getAllReports() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'reports',
    orderBy: 'createdAt DESC',
  );
  return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
}
Future<List<Report>> getReportsByStatus(String status) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'reports',
    where: 'status = ?',
    whereArgs: [status],
    orderBy: 'createdAt DESC',
  );
  return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
}

Future<int> updateReport(Report report) async {
  final db = await database;
  return await db.update(
    'reports',
    report.toMap(),
    where: 'id = ?',
    whereArgs: [report.id],
  );
}

Future<int> deleteReport(int id) async {
  final db = await database;
  return await db.delete(
    'reports',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<bool> hasUserReportedTarget(int targetId, String reportType) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'reports',
    where: 'targetId = ? AND reportType = ?',
    whereArgs: [targetId, reportType],
    limit: 1,
  );
  return maps.isNotEmpty;
}

// Update the database version number at the top of the file
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
