import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController namaController;
  late TextEditingController emailController;
  late TextEditingController noHpController;
  Uint8List? selectedPhotoBytes;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.user.nama);
    emailController = TextEditingController(text: widget.user.email);
    noHpController = TextEditingController(text: widget.user.noHp);
    selectedPhotoBytes = widget.user.photoBytes == null
        ? null
        : Uint8List.fromList(widget.user.photoBytes!);
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();

    setState(() {
      selectedPhotoBytes = bytes;
    });
  }

  void _removePhoto() {
    setState(() {
      selectedPhotoBytes = null;
    });
  }

  void save() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = User(
        username: widget.user.username,
        password: widget.user.password,
        nama: namaController.text,
        email: emailController.text,
        noHp: noHpController.text,
        photoBytes: selectedPhotoBytes,
      );

      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = namaController.text.trim();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final hasPhoto =
        selectedPhotoBytes != null && selectedPhotoBytes!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.blueGrey.shade200,
                      backgroundImage: hasPhoto
                          ? MemoryImage(selectedPhotoBytes!)
                          : null,
                      child: hasPhoto
                          ? null
                          : Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text("Pilih foto"),
                        ),
                        TextButton.icon(
                          onPressed: _removePhoto,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text("Hapus"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama"),
                validator: (value) =>
                    value!.isEmpty ? "Tidak boleh kosong" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.isEmpty ? "Tidak boleh kosong" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: noHpController,
                decoration: const InputDecoration(labelText: "No HP"),
                validator: (value) =>
                    value!.isEmpty ? "Tidak boleh kosong" : null,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: save,
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
