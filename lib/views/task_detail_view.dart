import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../viewmodels/user_view_model.dart';

class TaskDetailView extends StatelessWidget {
  final Task task;

  const TaskDetailView({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Tarih Formatlama
    String formattedDate = task.deadline;
    try {
      final date = DateTime.parse(task.deadline);
      formattedDate = DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {}

    final userViewModel = context.watch<UserViewModel>();
    final assignees = userViewModel.users
        .where((user) => task.assigneeIds.contains(user.id))
        .toList();

    // Sadece içeriği döndürüyoruz
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Durum
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(task.status.name, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tarih
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              const SizedBox(width: 8),
              Text(formattedDate, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),

          // Açıklama
          const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(task.description, style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
          const SizedBox(height: 24),

          // Kişiler
          if (assignees.isNotEmpty) ...[
            const Text("Assignees", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: assignees.map((user) => Chip(
                avatar: CircleAvatar(
                  backgroundImage: (user.profilePictureUrl != null) ? NetworkImage(user.profilePictureUrl!) : null,
                  child: (user.profilePictureUrl == null) ? Text(user.name[0]) : null,
                ),
                label: Text(user.name),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}