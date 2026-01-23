import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../viewmodels/user_view_model.dart';
import '../models/user_model.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  List<int> _selectedUserIds = [];

  TaskStatus _selectedStatus = TaskStatus.TODO;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      // TARİHİ OTOMATİK ALIYORUZ (BUGÜN)
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      try {
        await context.read<TaskViewModel>().addTask(
          _titleController.text,
          _descController.text,
          formattedDate,
          _selectedStatus,
          _selectedUserIds,
        );

        if (mounted) {
          Navigator.pop(context); // Pencereyi kapat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully! 🚀'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dialog Widget'ı ekranın ortasında pencere açar
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.all(20), // Kenarlardan boşluk
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Kısım: Başlık ve Kapatma Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "New Task",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                hint: "Title",
              ),
              const SizedBox(height: 12),

              // 2. Description Input
              _buildFigmaInput(
                controller: _descController,
                hint: "Description",
                maxLines: 4,
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

                  if (selectedNames.isEmpty) selectedNames = "Assignees"; // Kimse seçili değilse

                  return GestureDetector(
                    onTap: () {
                      // Tıklayınca Seçim Ekranını Aç
                      _showMultiSelectDialog(context, userViewModel.users);
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
              const SizedBox(height: 24),

              // 5. Save Button
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
                      : const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Input Widget
  Widget _buildFigmaInput({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? '$hint cannot be empty' : null,
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

  void _showMultiSelectDialog(BuildContext context, List<User> users) {
    showDialog(
      context: context,
      builder: (ctx) {
        // Dialog içinde seçim yaparken ekranın güncellenmesi için StatefulBuilder lazım
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Assignees"),
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