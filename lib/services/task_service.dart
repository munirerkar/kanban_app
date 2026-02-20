import 'package:dio/dio.dart';
import 'package:kanban_project/core/network/api_client.dart';
import 'package:kanban_project/models/task_model.dart';
import 'package:kanban_project/models/task_status.dart';

class TaskService {
  final Dio _dio = ApiClient().dio;

  String _tasksBasePath(int workspaceId) => '/workspaces/$workspaceId/tasks';

  Future<List<Task>> getAllTasks({required int workspaceId}) async {
    try {
      final response = await _dio.get(_tasksBasePath(workspaceId));

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(Task.fromJson)
            .toList();
      }

      throw Exception('Tasks could not be loaded');
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Network error while loading tasks');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Task> createTask({
    required int workspaceId,
    required Task task,
  }) async {
    try {
      final response = await _dio.post(
        _tasksBasePath(workspaceId),
        data: {
          'title': task.title,
          'description': task.description,
          'status': task.status.toShortString,
          'deadline': task.deadline,
          'assigneeIds': task.assigneeIds,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data is Map<String, dynamic>) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Task could not be added');
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Network error while creating task');
    } catch (e) {
      throw Exception('Addition error: $e');
    }
  }

  Future<void> updateTaskStatus({
    required int workspaceId,
    required int taskId,
    required TaskStatus newStatus,
  }) async {
    try {
      await _dio.patch(
        '${_tasksBasePath(workspaceId)}/$taskId/status',
        queryParameters: {'status': newStatus.name},
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Network error while updating status');
    } catch (e) {
      throw Exception('Status could not be updated: $e');
    }
  }

  Future<Task> updateTask({
    required int workspaceId,
    required Task task,
  }) async {
    try {
      final response = await _dio.put(
        '${_tasksBasePath(workspaceId)}/${task.id}',
        data: task.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Update response format is invalid');
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Network error while updating task');
    } catch (e) {
      throw Exception('Update error: $e');
    }
  }

  Future<void> setFavorite({
    required int workspaceId,
    required int taskId,
    required bool favorite,
  }) async {
    try {
      await _dio.patch(
        '${_tasksBasePath(workspaceId)}/$taskId/favorite',
        queryParameters: {'favorite': favorite},
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Network error while updating favorite');
    } catch (e) {
      throw Exception('Set favorite error: $e');
    }
  }

  Future<void> deleteTask({
    required int workspaceId,
    required int id,
  }) async {
    try {
      await _dio.delete('${_tasksBasePath(workspaceId)}/$id');
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Network error while deleting task');
    } catch (e) {
      throw Exception('Delete error: $e');
    }
  }

  Future<void> reorderTasks({
    required int workspaceId,
    required List<Map<String, dynamic>> orders,
  }) async {
    try {
      await _dio.patch('${_tasksBasePath(workspaceId)}/reorder', data: orders);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Network error while reordering tasks');
    } catch (e) {
      throw Exception('Reorder error: $e');
    }
  }

  String? _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return e.message;
  }
}