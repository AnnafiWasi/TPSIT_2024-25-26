import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';
import 'notifier.dart';
import 'widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'am043 todo list',
      theme:
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      home: ChangeNotifierProvider<TodoListNotifier>(
        create: (notifier) => TodoListNotifier(),
        child: const MyHomePage(title: 'am043 todo list'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayDialog(TodoListNotifier notifier, int cardIndex) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('add todo item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'type here ...'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                notifier.addTodoToCard(cardIndex, _textFieldController.text);
                _textFieldController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TodoListNotifier notifier = context.watch<TodoListNotifier>();

    return Scaffold(
      appBar: AppBar(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        title: Text(widget.title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifier.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, cardIndex) {
          List<Todo> todos = notifier.getTodosForCard(cardIndex);
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      Todo todo = todos[index];
                      return Row(
                        children: [
                          Checkbox(
                            value: todo.checked,
                            onChanged: (bool? value) {
                              notifier.changeTodo(todo);
                            },
                          ),
                          Expanded(child: TodoItem(todo: todo)),
                        ],
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _displayDialog(notifier, cardIndex),
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.addCard(),
        tooltip: 'add card',
        child: const Icon(Icons.add),
      ),
    );
  }
}
