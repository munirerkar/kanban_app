import 'package:dio/dio.dart';
import 'package:kanban_project/core/network/api_client.dart';
import 'package:kanban_project/models/user_model.dart';
import 'package:kanban_project/models/workspace_model.dart';

class WorkspaceService {
  WorkspaceService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<Workspace>> getMyWorkspaces() async {
    try {
      final response = await _dio.get('/workspaces');

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List<dynamic>;

        return data
            .whereType<Map<String, dynamic>>()
            .map(Workspace.fromJson)
            .toList();
      }

      if (response.statusCode == 204) {
        return [];
      }

      throw Exception('Workspaces could not be loaded');
    } on DioException catch (e) {
      final dynamic data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error while loading workspaces');
    } catch (e) {
      throw Exception('An error occurred while loading workspaces: $e');
    }
  }

  Future<List<User>> getWorkspaceMembers(int workspaceId) async {
    try {
      final response = await _dio.get('/workspaces/$workspaceId/members');

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List<dynamic>;

        return data
            .whereType<Map<String, dynamic>>()
            .map(_mapMemberToUser)
            .toList();
      }

      if (response.statusCode == 204) {
        return [];
      }

      throw Exception('Workspace members could not be loaded');
    } on DioException catch (e) {
      final dynamic data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error while loading workspace members');
    } catch (e) {
      throw Exception('An error occurred while loading workspace members: $e');
    }
  }

  User _mapMemberToUser(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();

    return User(
      id: _parseInt(json['userId']),
      name: fullName,
      email: null,
      profilePictureUrl: null,
    );
  }

  int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
