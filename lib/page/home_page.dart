import 'package:flutter/material.dart';
import '../model/task_model.dart';
import '../model/user_model.dart';
import 'task_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> get _recentCreated {
    final notes = [...taskList];
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  List<Task> get _sortedNotes {
    final notes = [...taskList];
    notes.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  String _notePreview(Task task) {
    final parts = <String>[];
    if (task.title.trim().isNotEmpty) {
      parts.add(task.title.trim());
    }
    if (task.content.trim().isNotEmpty) {
      parts.add(task.content.trim());
    }
    if (task.items.isNotEmpty) {
      parts.add('${task.doneItems}/${task.totalItems} checklist selesai');
    }

    return parts.isEmpty ? 'Belum ada isi' : parts.join(' • ');
  }

  void _toggleItem(Task task, int itemIndex) {
    setState(() {
      task.items[itemIndex].isDone = !task.items[itemIndex].isDone;
      task.updatedAt = DateTime.now();
    });
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Task task) {
    return Card(
      elevation: 0,
      color: task.color,
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
                  child: Text(
                    task.title.isEmpty ? 'Catatan tanpa judul' : task.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.pinned)
                  const Icon(Icons.push_pin, size: 18, color: Colors.black87),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _notePreview(task),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (task.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: task.completion,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.45),
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 6),
              Text(
                '${task.doneItems}/${task.totalItems} selesai',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Task task) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title.isEmpty ? 'Catatan tanpa judul' : task.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Dibuat ${_formatDate(task.createdAt)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if (task.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...task.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: item.isDone,
                  onChanged: (_) => _toggleItem(task, index),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      decoration: item.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tidak ada checklist',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _sortedNotes;
    final recentCreated = _recentCreated;
    final totalTask = notes.length;
    final totalItem = notes.fold<int>(0, (sum, task) => sum + task.totalItems);
    final doneItem = notes.fold<int>(0, (sum, task) => sum + task.doneItems);
    final pinnedCount = notes.where((task) => task.pinned).length;
    final progress = totalItem == 0 ? 0.0 : doneItem / totalItem;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Google Keep Style'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Selamat datang, ${widget.user.nama}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Catatan cepat, checklist, dan ide penting dalam satu tempat.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ringkasan catatan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalItem == 0
                                    ? 'Belum ada checklist aktif'
                                    : '$doneItem dari $totalItem checklist selesai',
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskPage(),
                              ),
                            ).then((_) {
                              if (!mounted) {
                                return;
                              }
                              setState(() {});
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Catatan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Kemajuan ${(progress * 100).toStringAsFixed(0)}%',
                        ),
                        const Spacer(),
                        Text('$pinnedCount disematkan'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Catatan',
                  '$totalTask',
                  Colors.blue,
                  Icons.note,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Disematkan',
                  '$pinnedCount',
                  Colors.orange,
                  Icons.push_pin,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Selesai',
                  '$doneItem',
                  Colors.green,
                  Icons.check_circle,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Riwayat membuat catatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (recentCreated.isEmpty)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Belum ada riwayat catatan',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              )
            else
              ...recentCreated.take(5).map(_buildHistoryCard),
            const SizedBox(height: 20),
            const Text(
              'Catatan terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (notes.isEmpty)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 54,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada catatan tersimpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Buka halaman catatan untuk mulai membuat ide, daftar, dan reminder.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...notes.take(4).map(_buildNoteCard),
            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskPage()),
          ).then((_) {
            if (!mounted) {
              return;
            }
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
