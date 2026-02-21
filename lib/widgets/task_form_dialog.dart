import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../viewmodels/workspace_view_model.dart';
import '../models/user_model.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? taskToEdit;
  const TaskFormDialog({super.key, this.taskToEdit});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;

  final List<int> _selectedUserIds = [];
  TaskStatus _selectedStatus = TaskStatus.TODO;
  DateTime? selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // EĞER DÜZENLEME İSE VERİLERİ DOLDUR
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController = TextEditingController(text: t.title);
      _descController = TextEditingController(text: t.description);
      _selectedStatus = t.status;
      _selectedUserIds.addAll(t.assigneeIds);
      try {
        selectedDate = DateTime.parse(t.deadline);
      } catch (_) {}
    } else {
      // EĞER YENİ EKLEME İSE BOŞ BAŞLAT
      _titleController = TextEditingController();
      _descController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      if (selectedDate == null) {
        // Handle case where date is not selected
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.formSelectDeadlineHint), backgroundColor: Colors.red),
        );
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      try {
        final viewModel = context.read<TaskViewModel>();

        if (widget.taskToEdit != null) {
          // --- DÜZENLEME MODU (UPDATE) ---
          final updatedTask = widget.taskToEdit!.copyWith(
            title: _titleController.text,
            description: _descController.text,
            status: _selectedStatus,
            deadline: formattedDate,
            assigneeIds: _selectedUserIds,
          );
          await viewModel.updateTaskFull(context, updatedTask);
        } else {
          // --- EKLEME MODU (ADD) ---
          await viewModel.addTask(
            context,
            _titleController.text,
            _descController.text,
            formattedDate,
            _selectedStatus,
            _selectedUserIds,
          );
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.taskToEdit != null ? l10n.formTaskUpdatedSuccess : l10n.formTaskCreatedSuccess),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.formError(e.toString())), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Dialog Widget'ı ekranın ortasında pencere açar
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.all(20), // Kenarlardan boşluk
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Kısım: Başlık ve Kapatma Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.taskToEdit != null ? l10n.formEditTaskTitle : l10n.formNewTaskTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Title Input
              _buildTextFormField(
                controller: _titleController,
                hint: l10n.formTitleHint,
                l10n: l10n,
                theme: theme
              ),
              const SizedBox(height: 12),

              
              // 2. Description Input
              _buildTextFormField(
                controller: _descController,
                hint: l10n.formDescriptionHint,
                maxLines: 4,
                l10n: l10n,
                theme: theme
              ),
              const SizedBox(height: 12),

              // 3. Status Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurfaceVariant),
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status.name,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Assignee
              Consumer<WorkspaceViewModel>(
                builder: (context, workspaceViewModel, child) {
                  final members = workspaceViewModel.workspaceMembers;

                  String selectedNames = members
                      .where((user) => _selectedUserIds.contains(user.id))
                      .map((user) => user.name)
                      .join(", ");

                  bool isAssigneeHint = selectedNames.isEmpty;
                  if (isAssigneeHint) selectedNames = l10n.formAssigneesHint;

                  return GestureDetector(
                    onTap: () => _showMultiSelectDialog(context, members, l10n, theme),
                    child: _buildDropdownContainer(theme,
                      child: Row(
                        children: [
                          Icon(Icons.people_outline, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedNames,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isAssigneeHint ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 5. TARİH SEÇİCİ
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: _buildDropdownContainer(theme,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? l10n.formSelectDeadlineHint // Hiçbir şey seçilmediyse
                            : DateFormat('dd MMMM yyyy').format(selectedDate!),
                        style: theme.textTheme.titleMedium,
                      ),
                      Icon(
                        Icons.calendar_today_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 6. Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                      : Text(
                          widget.taskToEdit != null ? l10n.formSaveChanges : l10n.formCreateTask,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Container _buildDropdownContainer(ThemeData theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required AppLocalizations l10n,
    required ThemeData theme,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => (value == null || value.isEmpty) ? l10n.formCannotBeEmpty(hint) : null,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context, List<User> users, AppLocalizations l10n, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(l10n.formAssigneesHint),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUserIds.contains(user.id);

                    return CheckboxListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty)
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                            child: (user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 14)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            _selectedUserIds.add(user.id);
                          } else {
                            _selectedUserIds.remove(user.id);
                          }
                        });
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}