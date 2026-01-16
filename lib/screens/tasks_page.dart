import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_planner/models/task.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  Box? _tasksBox;
  String _taskText = "";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 DEFINING APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: const Color(0xFF1E88E5),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Daily Planner",
          style: TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildTasks()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search tasks...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildTaskList() {
    final allTasks = _tasksBox!.values.toList();

    final filteredTasks = allTasks.where((task) {
      final t = Task.fromMap(task);
      return t.todo.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = Task.fromMap(filteredTasks[index]);
        final realIndex = allTasks.indexOf(filteredTasks[index]);

        return _TaskCard(
          task: task,
          onToggle: () {
            task.done = !task.done;
            _tasksBox!.putAt(realIndex, task.toMap());
            setState(() {});
          },
          onDelete: () => _confirmDelete(realIndex),
        );
      },
    );
  }

  Widget _buildTasks() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _tasksBox = snapshot.data;
          return _buildTaskList();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Task"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter task"),
            onChanged: (value) => _taskText = value,
            onSubmitted: (_) => _saveTask(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _saveTask() {
    if (_taskText.trim().isEmpty) return;

    final task = Task(
      todo: _taskText.trim(),
      timeStamp: DateTime.now(),
      done: false,
    );

    _tasksBox!.add(task.toMap());
    _taskText = "";
    setState(() {});
    Navigator.pop(context);
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _tasksBox!.deleteAt(index);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("dd/MM/yyyy").format(task.timeStamp);
    final time = DateFormat("hh:mm a").format(task.timeStamp);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onToggle,
        onLongPress: onDelete,

        leading: Icon(
          task.done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.done ? Colors.grey : const Color(0xFF1E88E5),
        ),

        title: Text(
          task.todo,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done ? Colors.grey : const Color(0xFF0D47A1),
            fontWeight: FontWeight.w500,
          ),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(date, style: const TextStyle(fontSize: 12)),
            Text(time, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
