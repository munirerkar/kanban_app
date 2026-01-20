import 'package:dio/dio.dart';
import '../models/task_model.dart';

class TaskService {
  final String _baseUrl = 'http://10.0.2.2:8080/api/tasks';

  final Dio _dio = Dio();

  // Tüm görevleri getir
  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Görevler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
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
        throw Exception('Görev eklenemedi');
      }
    } catch (e) {
      throw Exception('Ekleme hatası: $e');
    }
  }
}