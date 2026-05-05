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
        elevation: 6,
        shadowColor: Colors.black12,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Task task) {
    // Jika task.color sangat gelap, gunakan teks putih, tapi idealnya soft color
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      color: task.color == Colors.transparent ? Colors.white : task.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.pinned)
                  const Icon(
                    Icons.push_pin,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _notePreview(task),
              maxLines: 3,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
              overflow: TextOverflow.ellipsis,
            ),
            if (task.items.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: task.completion,
                  minHeight: 6,
                  backgroundColor: Colors.black12,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${task.doneItems}/${task.totalItems} selesai',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Task task) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title.isEmpty ? 'Catatan tanpa judul' : task.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Dibuat ${_formatDate(task.createdAt)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            if (task.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...task.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  activeColor: Colors.blueAccent,
                  value: item.isDone,
                  onChanged: (_) => _toggleItem(task, index),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      color: item.isDone ? Colors.grey : Colors.black87,
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
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
      backgroundColor: Colors.grey[100], // Diselaraskan dengan LoginPage
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.blueAccent,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // Header Greeting
            Text(
              'Halo, ${widget.user.nama.split(" ").first}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola catatan cepat, checklist, dan ide penting Anda di satu tempat.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Card Ringkasan Utama
            Card(
              elevation: 8,
              shadowColor: Colors.black12,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                                'Progress Checklist',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                totalItem == 0
                                    ? 'Belum ada checklist aktif'
                                    : '$doneItem dari $totalItem tugas selesai',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskPage(),
                              ),
                            ).then((_) {
                              if (!mounted) return;
                              setState(() {});
                            });
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Baru'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selesai ${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$pinnedCount Disematkan',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stat Row
            Row(
              children: [
                _buildStatCard(
                  'Catatan',
                  '$totalTask',
                  Colors.blueAccent,
                  Icons.note_alt_rounded,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Disematkan',
                  '$pinnedCount',
                  Colors.orangeAccent,
                  Icons.push_pin_rounded,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Selesai',
                  '$doneItem',
                  Colors.green,
                  Icons.check_circle_rounded,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section Catatan Terbaru
            const Text(
              'Catatan Tersimpan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (notes.isEmpty)
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.note_add_rounded,
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
                        'Klik tombol + di bawah untuk mulai menulis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...notes
                  .take(4)
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildNoteCard(task),
                    ),
                  ),

            const SizedBox(height: 24),

            // Section Riwayat
            const Text(
              'Riwayat Checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recentCreated.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Belum ada riwayat aktivitas.')),
              )
            else
              ...recentCreated.take(5).map(_buildHistoryCard),

            const SizedBox(height: 100), // Spasi untuk FAB
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskPage()),
          ).then((_) {
            if (!mounted) return;
            setState(() {});
          });
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
