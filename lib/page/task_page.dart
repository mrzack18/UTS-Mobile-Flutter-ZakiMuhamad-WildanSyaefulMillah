import 'package:flutter/material.dart';
import '../model/task_model.dart';

// DATA GLOBAL
final List<Task> taskList = [];

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  // ✅ CREATE
  void addTask() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    taskList.add(
                      Task(
                        title: titleController.text,
                        description: descController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // ✅ UPDATE
  void editTask(int index) {
    TextEditingController titleController = TextEditingController(
      text: taskList[index].title,
    );
    TextEditingController descController = TextEditingController(
      text: taskList[index].description,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  taskList[index] = Task(
                    title: titleController.text,
                    description: descController.text,
                    isDone: taskList[index].isDone,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // ✅ DELETE
  void deleteTask(int index) {
    setState(() {
      taskList.removeAt(index);
    });
  }

  // ✅ TOGGLE DONE
  void toggleTask(int index) {
    setState(() {
      taskList[index] = Task(
        title: taskList[index].title,
        description: taskList[index].description,
        isDone: !taskList[index].isDone,
      );
    });
  }

  // ✅ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),

      body: taskList.isEmpty
          ? const Center(
              child: Text("Belum ada task", style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];

                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      task.isDone ? Icons.check_circle : Icons.circle_outlined,
                      color: task.isDone ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => toggleTask(index),
                  ),
                  title: Text(task.title),
                  subtitle: Text(task.description),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editTask(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteTask(index),
                      ),
                    ],
                  ),
                );
              },
            ),

      // ✅ BUTTON TAMBAH
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
