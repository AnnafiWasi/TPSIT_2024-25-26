import 'package:flutter/material.dart';
import 'model.dart';
import 'helper.dart';

class TodoListNotifier with ChangeNotifier {
  final _todos = <Todo>[];
  int _cardCount = 0;

  int get length => _cardCount;

  Future<void> loadFromDb() async {
    final todos = await DatabaseHelper.getTodos();
    print('=== loadFromDb: trovati ${todos.length} todos ===');
    for (var t in todos) {
      print(
        '  todo: id=${t.id}, name=${t.name}, cardIndex=${t.cardIndex}, checked=${t.checked}',
      );
    }
    _todos.clear();
    _todos.addAll(todos);
    if (_todos.isNotEmpty) {
      _cardCount =
          _todos.map((t) => t.cardIndex).reduce((a, b) => a > b ? a : b) + 1;
    }
    print('=== cardCount dopo load: $_cardCount ===');
    notifyListeners();
  }

  void addCard() {
    _cardCount++;
    notifyListeners();
  }

  Future<void> addTodoToCard(int cardIndex, String name) async {
    final todo = Todo(
      id: null,
      name: name,
      checked: false,
      cardIndex: cardIndex,
    );
    await DatabaseHelper.insertTodo(todo);
    print('=== insertTodo chiamato per card $cardIndex, name=$name ===');
    await loadFromDb();
  }

  Future<void> changeTodo(Todo todo) async {
    todo.checked = !todo.checked;
    await DatabaseHelper.updateTodo(todo);
    notifyListeners();
  }

  Future<void> deleteTodo(Todo todo) async {
    await DatabaseHelper.deleteTodo(todo);
    _todos.remove(todo);
    notifyListeners();
  }

  List<Todo> getTodosForCard(int cardIndex) {
    List<Todo> result = [];
    for (int i = 0; i < _todos.length; i++) {
      if (_todos[i].cardIndex == cardIndex) {
        result.add(_todos[i]);
      }
    }
    return result;
  }
}
