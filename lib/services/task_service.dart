import 'package:dio/dio.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';

class TaskService {
  final String _baseUrl = 'http://192.168.1.5:8080/api/tasks';

  final Dio _dio = Dio();

  // Tüm görevleri getir
  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _dio.get(_baseUrl);

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

  // Yeni görev ekle
  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post(
        _baseUrl,
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
  // Görev durumu güncelle
  Future<void> updateTaskStatus(int taskId, TaskStatus newStatus) async {
    try {
      // Backend'deki PATCH endpoint'ine istek atıyoruz
      await _dio.patch(
        '$_baseUrl/$taskId/status',
        queryParameters: {'status': newStatus.name}, // Enum ismini gönderiyoruz
      );
    } catch (e) {
      throw Exception('Status could not be updated: $e');
    }
  }
}