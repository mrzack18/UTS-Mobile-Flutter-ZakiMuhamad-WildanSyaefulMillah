import 'package:flutter/material.dart';
import '../model/task_model.dart';

final List<Task> taskList = [];

const List<Color> _keepPalette = [
  Color(0xFFFFF8B8),
  Color(0xFFFFF1E6),
  Color(0xFFE8F5E9),
  Color(0xFFE3F2FD),
  Color(0xFFF3E5F5),
  Color(0xFFFFEBEE),
  Color(0xFFE0F7FA),
  Color(0xFFF1F8E9),
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

    if (title.isEmpty && content.isEmpty && items.isEmpty) {
      return;
    }

    setState(() {
      taskList.insert(
        0,
        Task(
          title: title,
          content: content,
          items: items,
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
    isPinned = false;
    selectedColorIndex = 0;
  }

  Widget _buildComposer() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  isPinned ? 'Catatan disematkan' : 'Catatan cepat',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Judul',
                border: InputBorder.none,
              ),
            ),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis catatan...',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            ...itemControllers.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _removeItemField(i),
                      icon: const Icon(Icons.check_box_outline_blank),
                      splashRadius: 20,
                    ),
                    Expanded(
                      child: TextField(
                        controller: itemControllers[i],
                        decoration: const InputDecoration(
                          hintText: 'Item checklist',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: addItemField,
              icon: const Icon(Icons.add),
              label: const Text('Tambah item'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Warna catatan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Tema aktif',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _keepPalette[selectedColorIndex],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: addTask,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(int index, Task task) {
    final backgroundColor = task.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (task.content.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.content,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
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
                    color: task.pinned ? Colors.black87 : Colors.black54,
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
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => toggleItem(index, itemIndex),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item.isDone
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.text,
                            style: TextStyle(
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
            const SizedBox(height: 10),
            Row(
              children: [
                if (task.items.isNotEmpty)
                  Text(
                    '${task.doneItems}/${task.totalItems} selesai',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                  )
                else
                  Text(
                    'Catatan',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: 'Hapus catatan',
                  onPressed: () => deleteTask(index),
                  icon: const Icon(Icons.delete_outline),
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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Keep Notes'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildComposer(),
            ),
            const SizedBox(height: 8),
            if (_sortedTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada catatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat catatan cepat, checklist, dan sematkan yang penting seperti Google Keep.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
