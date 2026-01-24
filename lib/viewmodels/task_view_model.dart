import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Backend'den Verileri Çek
  Future<void> fetchTasks() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _tasks = await _taskService.getAllTasks();
    } catch (e) {
      _errorMessage = "Görevler yüklenirken hata oluştu: $e";
    } finally {
      _setLoading(false);
    }
  }

  // Yeni Görev Ekle
  Future<void> addTask(String title, String description, String deadline, TaskStatus status, List<int> assigneeIds) async {
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
      _errorMessage = "Ekleme başarısız: $e";
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Görev güncelle
  Future<void> updateStatus(Task task, TaskStatus newStatus) async {
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
        _errorMessage = "Güncelleme başarısız, geri alındı.";
        notifyListeners();
      }
    }
  }
}