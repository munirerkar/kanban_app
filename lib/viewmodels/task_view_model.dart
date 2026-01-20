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
  Future<void> addTask(String title, String description, String deadline, TaskStatus status) async {
    _setLoading(true);
    try {
      final newTask = Task(
        title: title,
        description: description,
        deadline: deadline,
        status: status,
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
}