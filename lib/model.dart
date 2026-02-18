class Todo {
  Todo({
    required this.id,
    required this.name,
    required this.checked,
    required this.cardIndex,
  });
  final int? id;
  final String name;
  bool checked;
  int cardIndex;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'checked': checked ? 1 : 0,
      'cardIndex': cardIndex,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      name: map['name'],
      checked: map['checked'] == 1,
      cardIndex: map['cardIndex'],
    );
  }
}
