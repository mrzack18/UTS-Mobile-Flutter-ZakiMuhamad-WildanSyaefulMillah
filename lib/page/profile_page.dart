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

  // 🔴 logout + konfirmasi modern
  void logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            const Text(
              "Konfirmasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun ini?",
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Batal",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk baris info profil
  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blueAccent, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
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
      backgroundColor: Colors.grey[100], // Background selaras
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              tooltip: 'Edit Profil',
              icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
              onPressed: goToEdit,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Profil dengan dekorasi
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: hasPhoto ? MemoryImage(photoBytes!) : null,
                    child: hasPhoto
                        ? null
                        : Text(
                            _initialFromName(user.nama),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nama & Jabatan singkat
              Text(
                user.nama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "@${user.username}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Card Informasi Detail
              Card(
                elevation: 6,
                shadowColor: Colors.black12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      Icons.person_outline_rounded,
                      "Nama Lengkap",
                      user.nama,
                    ),
                    Divider(
                      indent: 72,
                      endIndent: 20,
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                    _buildInfoItem(
                      Icons.alternate_email_rounded,
                      "Username",
                      user.username,
                    ),
                    Divider(
                      indent: 72,
                      endIndent: 20,
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                    _buildInfoItem(
                      Icons.email_outlined,
                      "Alamat Email",
                      user.email,
                    ),
                    Divider(
                      indent: 72,
                      endIndent: 20,
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                    _buildInfoItem(
                      Icons.phone_outlined,
                      "Nomor Handphone",
                      user.noHp,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.redAccent.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onPressed: logout,
                  icon: const Icon(Icons.logout_rounded, size: 22),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
