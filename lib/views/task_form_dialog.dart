import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../viewmodels/user_view_model.dart';
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

      // Artık 'DateTime.now()' değil, seçilen tarihi gönderiyoruz
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
    // Dialog Widget'ı ekranın ortasında pencere açar
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Title Input
              _buildFigmaInput(
                controller: _titleController,
                hint: l10n.formTitleHint,
                l10n: l10n
              ),
              const SizedBox(height: 12),

              // 2. Description Input
              _buildFigmaInput(
                controller: _descController,
                hint: l10n.formDescriptionHint,
                maxLines: 4,
                l10n: l10n
              ),
              const SizedBox(height: 12),

              // 3. Status Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status.name,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Assignee
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  // Seçilen kişilerin isimlerini bulup virgülle birleştirir (Örn: "Ahmet, Ayşe")
                  String selectedNames = userViewModel.users
                      .where((user) => _selectedUserIds.contains(user.id))
                      .map((user) => user.name)
                      .join(", ");

                  if (selectedNames.isEmpty) selectedNames = l10n.formAssigneesHint; // Kimse seçili değilse

                  return GestureDetector(
                    onTap: () {
                      // Tıklayınca Seçim Ekranını Aç
                      _showMultiSelectDialog(context, userViewModel.users, l10n);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people_outline, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedNames,
                              style: TextStyle(
                                color: _selectedUserIds.isEmpty
                                    ? Colors.grey[600]
                                    : Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
                  // Takvimi Aç
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );

                  // Tarih seçildiyse state'i güncelle
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? l10n.formSelectDeadlineHint // Hiçbir şey seçilmediyse
                            : DateFormat('dd MMMM yyyy').format(selectedDate!),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.grey[500],
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
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                      widget.taskToEdit != null ? l10n.formSaveChanges : l10n.formCreateTask,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
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
  // Input Widget
  Widget _buildFigmaInput({
    required TextEditingController controller,
    required String hint,
    required AppLocalizations l10n,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? l10n.formCannotBeEmpty(hint) : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context, List<User> users, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) {
        // Dialog içinde seçim yaparken ekranın güncellenmesi için StatefulBuilder lazım
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
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
                          // Ufak Avatar
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
                          Text(user.name),
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
                        // Ana ekranı da güncelle ki arkadaki input alanı değişsin
                        this.setState(() {});
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