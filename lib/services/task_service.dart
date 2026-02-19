import 'package:dio/dio.dart';
import 'package:kanban_project/core/network/api_client.dart';
import '../core/app_constants.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';

class TaskService {

  final Dio _dio = ApiClient().dio;

  // Tüm görevleri getir (READ)
  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _dio.get(AppConstants.tasksEndpoint);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Tasks could not be loaded');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Yeni görev ekle (ADD)
  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post(
        AppConstants.tasksEndpoint,
        data: task.toJson(),
      );

      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else {
        throw Exception('Task could not be added');
      }
    } catch (e) {
      throw Exception('Addition error: $e');
    }
  }
  // Görev durumu güncelle (UPDATE)
  Future<void> updateTaskStatus(int taskId, TaskStatus newStatus) async {
    try {
      // Backend'deki PATCH endpoint'ine istek atıyoruz
      await _dio.patch(
        '${AppConstants.tasksEndpoint}/$taskId/status',
        queryParameters: {'status': newStatus.name}, // Enum ismini gönderiyoruz
      );
    } catch (e) {
      throw Exception('Status could not be updated: $e');
    }
  }
  // Görev güncelle (UPDATE)
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _dio.put(
        '${AppConstants.tasksEndpoint}/${task.id}',
        data: task.toJson(),
      );
      return Task.fromJson(response.data);
    } catch (e) {
      throw Exception('Update error: $e');
    }
  }

  // Toggle favorite
  Future<void> setFavorite(int taskId, bool favorite) async {
    try {
      await _dio.patch('${AppConstants.tasksEndpoint}/$taskId/favorite', queryParameters: {'favorite': favorite});
    } catch (e) {
      throw Exception('Set favorite error: $e');
    }
  }

  // Görev silme (DELETE)
  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('${AppConstants.tasksEndpoint}/$id');
    } catch (e) {
      throw Exception('Delete error: $e');
    }
  }

  // Reorder tasks in backend (bulk)
  Future<void> reorderTasks(List<Map<String, dynamic>> orders) async {
    try {
      await _dio.patch('${AppConstants.tasksEndpoint}/reorder', data: orders);
    } catch (e) {
      throw Exception('Reorder error: $e');
    }
  }
}