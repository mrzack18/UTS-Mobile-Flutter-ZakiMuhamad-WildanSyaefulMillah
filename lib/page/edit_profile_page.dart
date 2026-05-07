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

  // Helper widget untuk modern text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "$label tidak boleh kosong" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = namaController.text.trim();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final hasPhoto =
        selectedPhotoBytes != null && selectedPhotoBytes!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Background selaras
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: SingleChildScrollView(
        // Mencegah overflow keyboard
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Bagian Edit Foto
              Center(
                child: Column(
                  children: [
                    Container(
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
                        backgroundImage: hasPhoto
                            ? MemoryImage(selectedPhotoBytes!)
                            : null,
                        child: hasPhoto
                            ? null
                            : Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            foregroundColor: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _pickPhoto,
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            "Pilih Foto",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (hasPhoto)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _removePhoto,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              "Hapus Foto",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bagian Form Data Diri
              Card(
                elevation: 6,
                shadowColor: Colors.black12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Pribadi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: namaController,
                          label: "Nama Lengkap",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: emailController,
                          label: "Alamat Email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: noHpController,
                          label: "Nomor Handphone",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: save,
                  icon: const Icon(Icons.save_rounded, size: 22),
                  label: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
