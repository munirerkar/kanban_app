import 'package:dio/dio.dart';
import 'package:kanban_project/core/app_constants.dart';
import 'package:kanban_project/core/network/api_client.dart';
import 'package:kanban_project/models/user_model.dart';
import 'package:kanban_project/models/workspace_model.dart';

class WorkspaceService {
  WorkspaceService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<Workspace>> getMyWorkspaces() async {
    try {
      final response = await _dio.get(AppConstants.workspacesEndpoint);

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
      final response = await _dio.get(
        AppConstants.workspaceMembersEndpoint(workspaceId),
      );

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

  Future<Workspace> updateWorkspace(String workspaceId, String newName) async {
    try {
      final parsedWorkspaceId = int.tryParse(workspaceId);
      if (parsedWorkspaceId == null) {
        throw Exception('Invalid workspace id');
      }

      final response = await _dio.put(
        AppConstants.workspaceEndpoint(parsedWorkspaceId),
        data: {
          'name': newName,
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Workspace.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Workspace could not be updated');
    } on DioException catch (e) {
      final dynamic data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error while updating workspace');
    } catch (e) {
      throw Exception('An error occurred while updating workspace: $e');
    }
  }

  Future<void> deleteWorkspace({required int workspaceId}) async {
    try {
      final response = await _dio.delete(
        AppConstants.workspaceEndpoint(workspaceId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw Exception('Workspace could not be deleted');
    } on DioException catch (e) {
      final dynamic data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error while deleting workspace');
    } catch (e) {
      throw Exception('An error occurred while deleting workspace: $e');
    }
  }

  Future<void> leaveWorkspace({required int workspaceId}) async {
    try {
      final response = await _dio.post(
        AppConstants.workspaceLeaveEndpoint(workspaceId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw Exception('Workspace could not be left');
    } on DioException catch (e) {
      final dynamic data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error while leaving workspace');
    } catch (e) {
      throw Exception('An error occurred while leaving workspace: $e');
    }
  }

  Future<void> reorderWorkspaces({required List<int> orderedWorkspaceIds}) async {
    try {
      final payload = <Map<String, dynamic>>[];

      for (var i = 0; i < orderedWorkspaceIds.length; i++) {
        payload.add({
          'workspaceId': orderedWorkspaceIds[i],
          'orderIndex': i + 1,
        });
      }

      final response = await _dio.patch(
        AppConstants.workspacesReorderEndpoint(),
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw Exception('Workspace order could not be updated');
    } on DioException catch (e) {
      final dynamic data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error while reordering workspaces');
    } catch (e) {
      throw Exception('An error occurred while reordering workspaces: $e');
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
