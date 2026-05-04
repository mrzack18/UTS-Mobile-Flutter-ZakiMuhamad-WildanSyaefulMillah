import 'package:flutter/material.dart';
import '../model/user_model.dart';
import 'task_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    int totalTask = taskList.length;
    int doneTask = taskList.where((task) => task.isDone).length;

    return Scaffold(
      appBar: AppBar(
  title: const Text("Home"),
  actions: [
    IconButton(
      icon: const Icon(Icons.person),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(user: user),
          ),
        );
      },
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 USER INFO
            Text(
              "Selamat datang, ${user.nama}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 📋 TASK CARD
            Card(
              child: ListTile(
                title: const Text("Task Saya"),
                subtitle: Text(
                  totalTask == 0
                      ? "Belum ada task"
                      : "$doneTask / $totalTask selesai",
                ),
                trailing: const Icon(Icons.arrow_forward),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
