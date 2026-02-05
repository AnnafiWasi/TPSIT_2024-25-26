import 'package:flutter/widgets.dart';

import 'model.dart';

class TodoListNotifier with ChangeNotifier {
  final _todos = <Todo>[];
  int _cardCount = 0;

  int get length => _cardCount;

  void addCard() {
    _cardCount++;
    notifyListeners();
  }

  void addTodoToCard(int cardIndex, String name) {
    _todos.add(Todo(name: name, checked: false, cardIndex: cardIndex));
    notifyListeners();
  }

  void changeTodo(Todo todo) {
    todo.checked = !todo.checked;
    notifyListeners();
  }

  void deleteTodo(Todo todo) {
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
