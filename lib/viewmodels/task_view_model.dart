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
  Future<void> addTask(BuildContext context, String title, String description, String deadline, TaskStatus status, List<int> assigneeIds, {String? color}) async {
    final l10n = AppLocalizations.of(context)!;
    _setLoading(true);
    try {
      final newTask = Task(
        title: title,
        description: description,
        deadline: deadline,
        status: status,
        color: color,
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
    // Ensure favorites stay on top: split into fav and others
    final favs = tasksInStatus.where((t) => t.favorite).toList();
    final others = tasksInStatus.where((t) => !t.favorite).toList();

    final List<Task> groupList = [...favs, ...others];
    if (oldIndex < 0 || oldIndex >= groupList.length) return;

    // If moving across favorite boundary is attempted, constrain movement so favorites remain top
    final moved = groupList.removeAt(oldIndex);

    // If moved is favorite, it cannot be placed after favs.length-1 (i.e., cannot go into others area)
    if (moved.favorite) {
      final maxIndex = favs.length - 1; // last allowed index for favorites before move
      final targetIndex = newIndex.clamp(0, maxIndex);
      groupList.insert(targetIndex, moved);
    } else {
      // Non-favorite cannot be inserted before favs (i.e., index < favs.length)
      final minIndex = favs.length;
      final targetIndex = newIndex.clamp(minIndex, groupList.length);
      groupList.insert(targetIndex, moved);
    }

    // Create updated list with new orderIndex values within the status
    final List<Task> updatedTasksInStatus = [];
    for (int i = 0; i < groupList.length; i++) {
      updatedTasksInStatus.add(groupList[i].copyWith(orderIndex: i));
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
            'favorite': t.favorite,
          }).toList();

      _taskService.reorderTasks(List<Map<String, dynamic>>.from(orders));
    } catch (e) {
      _errorMessage = 'Sıralama kaydedilemedi: $e';
      notifyListeners();
    }
  }

  // Toggle favorite for a task and persist
  Future<void> toggleFavorite(BuildContext context, Task task) async {
    final l10n = AppLocalizations.of(context)!;
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final updatedTask = task.copyWith(favorite: !task.favorite);

    // Separate tasks for the affected status
    final status = updatedTask.status;
    final tasksInStatus = _tasks.where((t) => t.status == status && t.id != task.id).toList();
    
    // Group them by favorite status
    final favs = tasksInStatus.where((t) => t.favorite).toList();
    final others = tasksInStatus.where((t) => !t.favorite).toList();

    // Place the updated task in the correct group
    if (updatedTask.favorite) {
      favs.insert(0, updatedTask); // Add to top of favorites
    } else {
      others.insert(0, updatedTask); // Add to top of non-favorites
    }

    // Re-combine and re-index the entire column
    final newStatusList = <Task>[];
    int currentOrderIndex = 0;
    for (var t in favs) {
      newStatusList.add(t.copyWith(orderIndex: currentOrderIndex++));
    }
    for (var t in others) {
      newStatusList.add(t.copyWith(orderIndex: currentOrderIndex++));
    }
    
    // Rebuild the main task list
    final otherTasks = _tasks.where((t) => t.status != status).toList();
    _tasks = [...newStatusList, ...otherTasks];
    
    notifyListeners(); // Optimistic UI update

    // Persist the changes to the backend using the reorder endpoint
    try {
      final orders = newStatusList.map((t) => {
            'id': t.id,
            'orderIndex': t.orderIndex,
            'status': t.status.toShortString,
            'favorite': t.favorite,
          }).toList();
      await _taskService.reorderTasks(List<Map<String, dynamic>>.from(orders));
    } catch (e) {
      _errorMessage = l10n.viewModelUpdateFailed(e.toString());
      // NOTE: A rollback mechanism would be ideal here, but is complex.
      // For now, we just show an error. The user can refresh.
      notifyListeners();
    }
  }

  // Apply color to multiple selected tasks
  Future<void> applyColorToSelected(BuildContext context, String colorHex) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedTaskIds.isEmpty) return;

    _setLoading(true);
    try {
      // Update local tasks
      for (int i = 0; i < _tasks.length; i++) {
        if (_selectedTaskIds.contains(_tasks[i].id)) {
          _tasks[i] = _tasks[i].copyWith(color: colorHex);
        }
      }
      notifyListeners();

      // Persist changes one by one
      for (int id in _selectedTaskIds) {
        final task = _tasks.firstWhere((t) => t.id == id);
        await _taskService.updateTask(task);
      }

      // Clean up selection mode
      toggleSelectionMode(false);
    } catch (e) {
      _errorMessage = l10n.viewModelUpdateFailed(e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Set favorite for all selected tasks (true/false)
  Future<void> setFavoriteForSelected(BuildContext context, bool favorite) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedTaskIds.isEmpty) return;

    // Update local and persist
    for (int i = 0; i < _tasks.length; i++) {
      if (_selectedTaskIds.contains(_tasks[i].id)) {
        _tasks[i] = _tasks[i].copyWith(favorite: favorite);
      }
    }
    notifyListeners();

    try {
      for (int id in _selectedTaskIds) {
        await _taskService.setFavorite(id!, favorite);
      }
      // After favorites changed, re-fetch to get ordering consistent from backend
      await fetchTasks(context);
    } catch (e) {
      _errorMessage = l10n.viewModelUpdateFailed(e.toString());
      notifyListeners();
    }
  }
}
