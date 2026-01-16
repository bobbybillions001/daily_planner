class Task {
  final String todo;
  final DateTime timeStamp;
  bool done;

  Task({
    required this.todo,
    required this.timeStamp,
    this.done = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'todo': todo,
      'timeStamp': timeStamp.toIso8601String(),
      'done': done,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      todo: map['todo'] as String,

      // 🔥 THIS IS THE FIX
      timeStamp: map['timeStamp'] is DateTime
          ? map['timeStamp']
          : DateTime.parse(map['timeStamp']),

      done: map['done'] as bool,
    );
  }
}
