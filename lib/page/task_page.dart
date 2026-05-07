import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/task_model.dart';
import '../util/image_helper.dart';

final List<Task> taskList = [];

const List<Color> _keepPalette = [
  Color(0xFFFFFFFF), // Diubah warna pertama jadi putih default
  Color(0xFFFFF8B8),
  Color(0xFFFFF1E6),
  Color(0xFFE8F5E9),
  Color(0xFFE3F2FD),
  Color(0xFFF3E5F5),
  Color(0xFFFFEBEE),
  Color(0xFFE0F7FA),
];

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final List<TextEditingController> itemControllers = [TextEditingController()];
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> selectedImagePaths = [];
  bool isPinned = false;
  int selectedColorIndex = 0;

  List<Task> get _sortedTasks {
    final notes = [...taskList];
    notes.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    for (final controller in itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void addTask() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    final items = itemControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .map((text) => ChecklistItem(text: text))
        .toList();

    if (title.isEmpty &&
        content.isEmpty &&
        items.isEmpty &&
        selectedImagePaths.isEmpty) {
      return;
    }

    setState(() {
      taskList.insert(
        0,
        Task(
          title: title,
          content: content,
          items: items,
          imagePaths: List<String>.from(selectedImagePaths),
          pinned: isPinned,
          color: _keepPalette[selectedColorIndex],
        ),
      );

      _resetComposer();
    });
  }

  void addItemField() {
    setState(() {
      itemControllers.add(TextEditingController());
    });
  }

  void deleteTask(int index) {
    setState(() {
      taskList.removeAt(index);
    });
  }

  void toggleItem(int taskIndex, int itemIndex) {
    setState(() {
      taskList[taskIndex].items[itemIndex].isDone =
          !taskList[taskIndex].items[itemIndex].isDone;
      taskList[taskIndex].updatedAt = DateTime.now();
    });
  }

  void togglePin(int index) {
    setState(() {
      taskList[index].pinned = !taskList[index].pinned;
      taskList[index].updatedAt = DateTime.now();
    });
  }

  void _removeItemField(int index) {
    if (itemControllers.length == 1) {
      itemControllers.first.clear();
      return;
    }

    setState(() {
      itemControllers[index].dispose();
      itemControllers.removeAt(index);
    });
  }

  void _resetComposer() {
    titleController.clear();
    contentController.clear();
    for (int i = itemControllers.length - 1; i >= 0; i--) {
      itemControllers[i].dispose();
      itemControllers.removeAt(i);
    }
    itemControllers.add(TextEditingController());
    selectedImagePaths.clear();
    isPinned = false;
    selectedColorIndex = 0;
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage();
    if (images.isEmpty) {
      return;
    }

    setState(() {
      selectedImagePaths.addAll(
        images.map((image) => image.path).where((path) => path.isNotEmpty),
      );
    });
  }

  void _removeSelectedImage(int index) {
    setState(() {
      selectedImagePaths.removeAt(index);
    });
  }

  void _showImagePreview(String path) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: buildAdaptiveImage(path, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Composer
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.blueAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isPinned ? 'Catatan Disematkan' : 'Buat Catatan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Sematkan',
                  onPressed: () {
                    setState(() {
                      isPinned = !isPinned;
                    });
                  },
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isPinned ? Colors.blueAccent : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Input Judul
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Judul Catatan',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
            Divider(color: Colors.grey.shade200, thickness: 1),

            // Input Konten
            TextField(
              controller: contentController,
              maxLines: null,
              minLines: 2,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Tulis sesuatu di sini...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),

            // Checklist Items
            ...itemControllers.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _removeItemField(i),
                      borderRadius: BorderRadius.circular(20),
                      child: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red.shade300,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: itemControllers[i],
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Item checklist',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            TextButton.icon(
              onPressed: addItemField,
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text(
                'Tambah item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Warna Latar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Pilihan Warna
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_keepPalette.length, (index) {
                final color = _keepPalette[index];
                final isSelected = selectedColorIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColorIndex = index;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: index == 0
                                ? Colors.blueAccent
                                : Colors.black54,
                          )
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImages,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.photo_library_outlined, size: 20),
                  label: const Text(
                    'Tambah foto',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (selectedImagePaths.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${selectedImagePaths.length} foto',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ],
            ),
            if (selectedImagePaths.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(selectedImagePaths.length, (index) {
                  final path = selectedImagePaths[index];
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => _showImagePreview(path),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: buildAdaptiveImage(
                            path,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: InkWell(
                          onTap: () => _removeSelectedImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text(
                  'Simpan Catatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(int index, Task task) {
    final backgroundColor = task.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shadowColor: Colors.black12,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: backgroundColor == Colors.white
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title.isEmpty ? 'Catatan tanpa judul' : task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (task.content.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.content,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            height: 1.4,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: task.pinned ? 'Lepas sematan' : 'Sematkan',
                  onPressed: () => togglePin(index),
                  icon: Icon(
                    task.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: task.pinned
                        ? Colors.blueAccent
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            if (task.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...task.items.asMap().entries.map((entry) {
                final itemIndex = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => toggleItem(index, itemIndex),
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item.isDone
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 22,
                          color: item.isDone
                              ? Colors.blueAccent
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: item.isDone
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade800,
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            if (task.imagePaths.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(task.imagePaths.length, (imageIndex) {
                  final path = task.imagePaths[imageIndex];
                  return GestureDetector(
                    onTap: () => _showImagePreview(path),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: buildAdaptiveImage(
                        path,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (task.items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${task.doneItems}/${task.totalItems} selesai',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    'Catatan',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: 'Hapus catatan',
                  onPressed: () => deleteTask(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Background selaras dengan Home & Login
      appBar: AppBar(
        title: const Text(
          'Catatan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildComposer(),
            ),
            const SizedBox(height: 16),
            if (_sortedTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.note_alt_rounded,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada catatan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Buat catatan cepat, checklist, dan sematkan yang penting di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: _sortedTasks.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final task = _sortedTasks[index];
                  return _buildTaskCard(taskList.indexOf(task), task);
                },
              ),
          ],
        ),
      ),
    );
  }
}
