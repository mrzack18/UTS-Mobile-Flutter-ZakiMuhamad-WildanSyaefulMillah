import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../model/user_model.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;

  String _initialFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  // 🔹 ke halaman edit
  void goToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: user)),
    );

    if (result != null && result is User) {
      setState(() {
        user = result;
      });
    }
  }

  // 🔴 logout + konfirmasi
  void logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? photoBytes = user.photoBytes == null
        ? null
        : Uint8List.fromList(user.photoBytes!);
    final hasPhoto = photoBytes != null && photoBytes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: goToEdit),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.blueGrey.shade200,
                backgroundImage: hasPhoto ? MemoryImage(photoBytes!) : null,
                child: hasPhoto
                    ? null
                    : Text(
                        _initialFromName(user.nama),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Nama: ${user.nama}"),
            const SizedBox(height: 10),

            Text("Username: ${user.username}"),
            const SizedBox(height: 10),

            Text("Email: ${user.email}"),
            const SizedBox(height: 10),

            Text("No HP: ${user.noHp}"),

            const SizedBox(height: 30),

            // 🔴 tombol logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: logout,
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
