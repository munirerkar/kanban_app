import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task_model.dart';
import '../viewmodels/workspace_view_model.dart';

class TaskDetailView extends StatelessWidget {
  final Task task;

  const TaskDetailView({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Tarih Formatlama
    String formattedDate = task.deadline;
    try {
      final date = DateTime.parse(task.deadline);
      formattedDate = DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {}

    final workspaceViewModel = context.watch<WorkspaceViewModel>();
    final assignees = workspaceViewModel.workspaceMembers
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(task.status.name, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tarih
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(formattedDate, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 24),

          // Açıklama
          Text(l10n.taskDetailDescription, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(task.description, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          ),
          const SizedBox(height: 24),

          // Kişiler
          if (assignees.isNotEmpty) ...[
            Text(l10n.taskDetailAssignees, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
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