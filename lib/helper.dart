import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> _getDb() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'todos.db');
    _db = await openDatabase(path, version: 1, onCreate: _createTable);
    return _db!;
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
    CREATE TABLE todos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      checked INTEGER NOT NULL,
      cardIndex INTEGER NOT NULL
    );
    ''');
  }

  static Future<void> init() async {
    await _getDb();
  }

  static Future<List<Todo>> getTodos() async {
    Database db = await _getDb();
    final List<Map<String, dynamic>> result = await db.query('todos');
    if (result.isEmpty) return <Todo>[];
    return result.map((row) => Todo.fromMap(row)).toList();
  }

  static Future<void> insertTodo(Todo todo) async {
    Database db = await _getDb();
    await db.insert('todos', todo.toMap());
  }

  static Future<void> updateTodo(Todo todo) async {
    Database db = await _getDb();
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  static Future<void> deleteTodo(Todo todo) async {
    Database db = await _getDb();
    await db.delete('todos', where: 'id = ?', whereArgs: [todo.id]);
  }

  static Future<int> deleteAll() async {
    Database db = await _getDb();
    return await db.delete('todos');
  }
}

//adb shell run-as com.example.todo_list rm /data/data/com.example.todo_list/databases/todos.db
