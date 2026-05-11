import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'brawl_cache.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            tag TEXT PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_tag TEXT,
            player_tag TEXT,
            player_name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE player_cache (
            tag TEXT PRIMARY KEY,
            data TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS player_cache (
            tag TEXT PRIMARY KEY,
            data TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> saveUser(String tag) async {
    final dbClient = await db;
    await dbClient.insert('user', {'tag': tag},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String?> getUser() async {
    final dbClient = await db;
    final rows = await dbClient.query('user', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['tag'] as String?;
  }

  static Future<void> clearUser(String userTag) async {
    final dbClient = await db;
    await dbClient.delete('user');
    await dbClient.delete('favorites',
        where: 'user_tag = ?', whereArgs: [userTag]);
  }

  static Future<void> savePlayer(String tag, Map<String, dynamic> data) async {
    final dbClient = await db;
    await dbClient.insert(
      'player_cache',
      {'tag': tag, 'data': jsonEncode(data)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getPlayer(String tag) async {
    final dbClient = await db;
    final rows = await dbClient.query('player_cache',
        where: 'tag = ?', whereArgs: [tag]);
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['data'] as String);
  }

  static Future<void> addFavorite(String userTag, String playerTag, String playerName) async {
    final dbClient = await db;
    await dbClient.insert(
      'favorites',
      {'user_tag': userTag, 'player_tag': playerTag, 'player_name': playerName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getFavorites(String userTag) async {
    final dbClient = await db;
    return await dbClient.query('favorites',
        where: 'user_tag = ?', whereArgs: [userTag]);
  }

  static Future<Map<String, dynamic>?> getFavoriteByTag(String userTag, String playerTag) async {
    final dbClient = await db;
    final res = await dbClient.query('favorites',
        where: 'user_tag = ? AND player_tag = ?',
        whereArgs: [userTag, playerTag]);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<void> removeFavorite(String userTag, String playerTag) async {
    final dbClient = await db;
    await dbClient.delete('favorites',
        where: 'user_tag = ? AND player_tag = ?',
        whereArgs: [userTag, playerTag]);
  }

  static Future<bool> isFavorite(String userTag, String playerTag) async {
    final dbClient = await db;
    final res = await dbClient.query('favorites',
        where: 'user_tag = ? AND player_tag = ?',
        whereArgs: [userTag, playerTag]);
    return res.isNotEmpty;
  }
}