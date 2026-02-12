import 'package:flutter/material.dart';
import '../core/app_extensions.dart'; // Import the extension
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../models/user_model.dart';
import '../services/task_service.dart';
import '../l10n/app_localizations.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- ARAMA DURUMU (SEARCH STATE) ---
  bool _isSearchMode = false;
  String _searchQuery = '';

  // --- ÇOKLU SEÇİM (MULTI-SELECT) LOGIC ---
  final Set<int> _selectedTaskIds = {}; // Seçilenlerin ID listesi
  bool _isSelectionMode = false; // Seçim modu açık mı?

  // --- GETTERS ---
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSearchMode => _isSearchMode;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedTaskIds => _selectedTaskIds;

  List<Task> getTasksByStatus(TaskStatus status, List<User> allUsers) {
    // Önce statüye göre filtrele
    final statusFilteredTasks = _tasks.where((task) => task.status == status).toList();

    // Arama modu aktif değilse veya arama metni boşsa, olduğu gibi döndür
    if (!_isSearchMode || _searchQuery.isEmpty) {
      return statusFilteredTasks;
    }

    // Arama metnini ve aranacak alanları normalleştirerek filtrele
    final normalizedQuery = _searchQuery.toNormalized();
    return statusFilteredTasks.where((task) {
      final titleMatch = task.title.toNormalized().contains(normalizedQuery);
      final descriptionMatch = task.description.toNormalized().contains(normalizedQuery);

      // Atanan kullanıcıların isimlerinde ara (normalleştirilmiş)
      final assigneeMatch = task.assigneeIds.any((assigneeId) {
        try {
          final user = allUsers.firstWhere((user) => user.id == assigneeId);
          return user.name.toNormalized().contains(normalizedQuery);
        } catch (e) {
          return false; // User not found
        }
      });

      return titleMatch || descriptionMatch || assigneeMatch;
    }).toList();
  }

  // --- ARAMA FONKSİYONLARI (SEARCH FUNCTIONS) ---
  void toggleSearchMode(bool active) {
    _isSearchMode = active;
    if (active) {
      // Arama modu açıldığında, diğer modları kapat
      _isSelectionMode = false;
      _selectedTaskIds.clear();
    } else {
      _searchQuery = ''; // Arama modundan çıkınca metni temizle
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  // Backend'den Verileri Çek
  Future<void> fetchTasks(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    _setLoading(true);
    _errorMessage = null;

    try {
      _tasks = await _taskService.getAllTasks();
    } catch (e) {
      _errorMessage = l10n.viewModelAnErrorOccurredWhileLoadingTasks(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Yeni Görev Ekle
  Future<void> addTask(BuildContext context, String title, String description, String deadline, TaskStatus status, List<int> assigneeIds) async {
    final l10n = AppLocalizations.of(context)!;
    _setLoading(true);
    try {
      final newTask = Task(
        title: title,
        description: description,
        deadline: deadline,
        status: status,
        assigneeIds: assigneeIds,
      );
      final createdTask = await _taskService.createTask(newTask);
      _tasks.add(createdTask);
      notifyListeners();
    } catch (e) {
      _errorMessage = l10n.viewModelAdditionFailed(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Görev durumu güncelle
  Future<void> updateStatus(BuildContext context, Task task, TaskStatus newStatus) async {
    final l10n = AppLocalizations.of(context)!;
    // 1. Önce arayüzü hemen güncelle (Kullanıcı beklemesin - Optimistic Update)
    final oldStatus = task.status;

    // Listeden eski halini bul ve güncelle (Local Update)
    final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = task.copyWith(status: newStatus);
      notifyListeners();
    }

    // 2. Backend'e isteği gönder
    try {
      await _taskService.updateTaskStatus(task.id!, newStatus);
    } catch (e) {
      // Hata olursa değişikliği geri al!
      if (taskIndex != -1) {
        _tasks[taskIndex] = task.copyWith(status: oldStatus);
        _errorMessage = l10n.viewModelUpdateFailedRolledBack;
        notifyListeners();
      }
    }
  }

  // Görev güncelleme
  Future<void> updateTaskFull(BuildContext context, Task task) async {
    final l10n = AppLocalizations.of(context)!;
    _setLoading(true);
    try {
      final updatedTask = await _taskService.updateTask(task);

      // Listeden eskini bul, yenisiyle değiştir
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      if (_openedTask != null && _openedTask!.id == updatedTask.id) {
        _openedTask = updatedTask;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = l10n.viewModelUpdateFailed(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Görev silme
  Future<void> deleteTask(BuildContext context, int id) async {
    final l10n = AppLocalizations.of(context)!;
    _setLoading(true);
    try {
      await _taskService.deleteTask(id);

      // Listeden sil
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = l10n.viewModelDeletionFailed(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- ÇOKLU SEÇİM (MULTI-SELECT) LOGIC ---

  // Seçim modunu başlat/bitir
  void toggleSelectionMode(bool active) {
    _isSelectionMode = active;
    if (active) {
      // Seçim modu açılınca arama modunu kapat
      _isSearchMode = false;
      _searchQuery = '';
    } else {
      _selectedTaskIds.clear(); // Mod kapanırsa seçimleri temizle
    }
    notifyListeners();
  }

  // Bir karta tıklandığında seç/kaldır
  void toggleTaskSelection(int taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
      if (_selectedTaskIds.isEmpty) {
        _isSelectionMode = false; // Sonuncuyu da kaldırdıysa moddan çık
      }
    } else {
      _selectedTaskIds.add(taskId);
    }
    notifyListeners();
  }

  // Seçilenlerin hepsini sil
  Future<void> deleteSelectedTasks(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    _setLoading(true);
    try {
      // Backend'e tek tek silme isteği at (Veya backend'de toplu silme varsa o kullanılır)
      // Şimdilik döngüyle siliyoruz:
      for (int id in _selectedTaskIds) {
        await _taskService.deleteTask(id);
        _tasks.removeWhere((t) => t.id == id);
      }

      // Temizlik
      toggleSelectionMode(false);
    } catch (e) {
      _errorMessage = l10n.viewModelBulkDeleteError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- DETAY GÖRÜNÜMÜ YÖNETİMİ ---

  Task? _openedTask; // Şu an detayları görüntülenen görev (null ise pano açık)

  Task? get openedTask => _openedTask;

  // Görevi aç veya kapat (null gönderilirse kapatır)
  void setOpenedTask(Task? task) {
    _openedTask = task;
    // Eğer detay açılıyorsa seçim ve arama modlarını kapat, çakışmasınlar
    if (task != null) {
      _isSelectionMode = false;
      _selectedTaskIds.clear();
      _isSearchMode = false;
      _searchQuery = '';
    }
    notifyListeners();
  }

  void reorderLocalTasks(TaskStatus status, int oldIndex, int newIndex) {
    // Build the list of tasks in the given status without mutating _tasks yet
    final tasksInStatus = _tasks.where((t) => t.status == status).toList();
    if (oldIndex < 0 || oldIndex >= tasksInStatus.length) return;

    // Move within the status list
    final moved = tasksInStatus.removeAt(oldIndex);
    tasksInStatus.insert(newIndex, moved);

    // Create updated list with new orderIndex values
    final List<Task> updatedTasksInStatus = [];
    for (int i = 0; i < tasksInStatus.length; i++) {
      updatedTasksInStatus.add(tasksInStatus[i].copyWith(orderIndex: i));
    }

    // Keep other tasks as-is
    final otherTasks = _tasks.where((t) => t.status != status).toList();

    // Rebuild main list: status group first (preserve chosen grouping), then others
    _tasks = [...updatedTasksInStatus, ...otherTasks];

    notifyListeners();

    // Send reorder to backend (optimistic)
    try {
      final orders = updatedTasksInStatus.map((t) => {
            'id': t.id,
            'orderIndex': t.orderIndex,
            'status': t.status.toShortString,
          }).toList();

      _taskService.reorderTasks(List<Map<String, dynamic>>.from(orders));
    } catch (e) {
      _errorMessage = 'Sıralama kaydedilemedi: $e';
      notifyListeners();
    }
  }
}
