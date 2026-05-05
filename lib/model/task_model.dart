import 'package:flutter/material.dart';

class ChecklistItem {
  String text;
  bool isDone;

  ChecklistItem({required this.text, this.isDone = false});
}

class Task {
  String title;
  String content;
  List<ChecklistItem> items;
  bool pinned;
  bool archived;
  Color color;
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    required this.title,
    this.content = '',
    this.items = const [],
    this.pinned = false,
    this.archived = false,
    this.color = const Color(0xFFFFF8B8),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  int get totalItems => items.length;

  int get doneItems => items.where((item) => item.isDone).length;

  double get completion => totalItems == 0 ? 0 : doneItems / totalItems;

  bool get hasContent =>
      title.trim().isNotEmpty || content.trim().isNotEmpty || items.isNotEmpty;

  Task copyWith({
    String? title,
    String? content,
    List<ChecklistItem>? items,
    bool? pinned,
    bool? archived,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      title: title ?? this.title,
      content: content ?? this.content,
      items: items ?? this.items,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
