import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class LocalDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, 'litup.db');

    return await openDatabase(
      path,
      version: 2, // increment from 1 -> 2
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE polls(
        id TEXT PRIMARY KEY,
        partyId TEXT,
        question TEXT,
        options TEXT,
        createdAt INTEGER
      )
    ''');

        await db.execute('''
      CREATE TABLE parties(
        id TEXT PRIMARY KEY,
        name TEXT,
        host TEXT,
        imagePath TEXT,
        createdAt INTEGER
      )
    ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add createdAt column for existing users
          await db.execute('ALTER TABLE parties ADD COLUMN createdAt INTEGER');
        }
      },
    );
  }

  /// Cache party metadata + full image
  static Future<void> cacheParty(Map<String, dynamic> party) async {
    final db = await database;

    String? imagePath;
    if (party['imageUrl'] != null && party['imageUrl'].toString().isNotEmpty) {
      imagePath = await _downloadAndSaveImage(party['imageUrl'], party['id']);
    }

    await db.insert('parties', {
      'id': party['id'],
      'name': party['name'],
      'host': party['host'],
      'imagePath': imagePath,
      'createdAt': party['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String> _downloadAndSaveImage(String url, String id) async {
    final response = await http.get(Uri.parse(url));
    final documentsDir = await getApplicationDocumentsDirectory();
    final filePath = join(documentsDir.path, 'party_$id.png');
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /// Get cached parties
  static Future<List<Map<String, dynamic>>> getCachedParties() async {
    final db = await database;
    final results = await db.query('parties', orderBy: 'createdAt DESC');

    return results.map((row) {
      return {
        'id': row['id'],
        'name': row['name'],
        'host': row['host'],
        'imagePath': row['imagePath'],
        'createdAt': row['createdAt'],
      };
    }).toList();
  }

  /// Cache polls
  static Future<void> cachePoll(Map<String, dynamic> poll) async {
    final db = await database;
    await db.insert('polls', {
      'id': poll['id'],
      'partyId': poll['partyId'],
      'question': poll['question'],
      'options': jsonEncode(poll['options']),
      'createdAt': poll['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get cached polls for a party
  static Future<List<Map<String, dynamic>>> getCachedPolls(
    String partyId,
  ) async {
    final db = await database;
    final results = await db.query(
      'polls',
      where: 'partyId = ?',
      whereArgs: [partyId],
      orderBy: 'createdAt DESC',
    );
    return results;
  }

  static Future<void> removePartiesNotIn(Set<String> firestoreIds) async {
    final db = await database; 
    final cached = await db.query('parties');
    for (final row in cached) {
      if (!firestoreIds.contains(row['id'])) {
        await db.delete('parties', where: 'id = ?', whereArgs: [row['id']]);
      }
    }
  }
}
