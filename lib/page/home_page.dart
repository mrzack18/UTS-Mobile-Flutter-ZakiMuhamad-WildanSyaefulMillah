import 'package:flutter/material.dart';
import '../model/user_model.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(child: Text("Selamat datang, ${user.nama}")),
    );
  }
}
