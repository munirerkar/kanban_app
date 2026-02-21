import 'package:flutter/material.dart';
import 'package:kanban_project/models/user_model.dart';
import 'package:kanban_project/models/workspace_model.dart';
import 'package:kanban_project/services/workspace_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkspaceViewModel extends ChangeNotifier {
  WorkspaceViewModel({WorkspaceService? workspaceService})
      : _workspaceService = workspaceService ?? WorkspaceService();

  final WorkspaceService _workspaceService;

  List<Workspace> _workspaces = [];
  Workspace? _currentWorkspace;
  List<User> _workspaceMembers = [];
  bool _isLoading = false;
  bool _isMembersLoading = false;
  String? _errorMessage;
  String? _membersErrorMessage;

  int? _currentUserId;

  List<Workspace> get workspaces => _workspaces;
  List<Workspace> get myWorkspaces {
    if (_currentUserId == null) {
      return const [];
    }
    return _workspaces.where((workspace) => workspace.ownerId == _currentUserId).toList();
  }

  List<Workspace> get sharedWorkspaces {
    if (_currentUserId == null) {
      return const [];
    }
    return _workspaces.where((workspace) => workspace.ownerId != _currentUserId).toList();
  }

  Workspace? get currentWorkspace => _currentWorkspace;
  List<User> get workspaceMembers => _workspaceMembers;
  bool get isLoading => _isLoading;
  bool get isMembersLoading => _isMembersLoading;
  String? get errorMessage => _errorMessage;
  String? get membersErrorMessage => _membersErrorMessage;

  void setCurrentUser(User? user) {
    final nextId = user?.id;
    if (_currentUserId == nextId) {
      return;
    }

    _currentUserId = nextId;
    notifyListeners();
  }

  bool isOwnedByCurrentUser(Workspace workspace) {
    return _currentUserId != null && workspace.ownerId == _currentUserId;
  }

  Future<void> fetchWorkspaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedWorkspaces = await _workspaceService.getMyWorkspaces();
      _workspaces = fetchedWorkspaces;

      if (_workspaces.isEmpty) {
        _currentWorkspace = null;
        _workspaceMembers = [];
      } else {
        final currentId = _currentWorkspace?.id;
        final hasCurrent = currentId != null &&
            _workspaces.any((workspace) => workspace.id == currentId);

        if (hasCurrent) {
          _currentWorkspace = _workspaces.firstWhere((workspace) => workspace.id == currentId);
        } else {
          final lastOpenedWorkspaceId = await _readLastOpenedWorkspaceId();
          final hasLastOpened = lastOpenedWorkspaceId != null &&
              _workspaces.any((workspace) => workspace.id == lastOpenedWorkspaceId);

          if (hasLastOpened) {
            _currentWorkspace = _workspaces.firstWhere((workspace) => workspace.id == lastOpenedWorkspaceId);
          } else {
            final firstOwnedWorkspace = _findFirstOwnedWorkspace();
            _currentWorkspace = firstOwnedWorkspace ?? _workspaces.first;
          }
        }

        await _persistLastOpenedWorkspaceId(_currentWorkspace?.id);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWorkspaceMembers(int? workspaceId) async {
    if (workspaceId == null) {
      _workspaceMembers = [];
      _membersErrorMessage = null;
      notifyListeners();
      return;
    }

    _isMembersLoading = true;
    _membersErrorMessage = null;
    notifyListeners();

    try {
      final members = await _workspaceService.getWorkspaceMembers(workspaceId);
      _workspaceMembers = members;
    } catch (e) {
      _workspaceMembers = [];
      _membersErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isMembersLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectWorkspace(Workspace workspace) async {
    if (_currentWorkspace?.id == workspace.id) {
      return;
    }

    _currentWorkspace = workspace;
    _workspaceMembers = [];
    _membersErrorMessage = null;
    notifyListeners();

    await _persistLastOpenedWorkspaceId(workspace.id);
  }

  Future<bool> updateWorkspaceName(String id, String newName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedWorkspace = await _workspaceService.updateWorkspace(id, newName);
      final workspaceId = int.tryParse(id);
      if (workspaceId == null) {
        _errorMessage = 'Invalid workspace id';
        return false;
      }

      final index = _workspaces.indexWhere((workspace) => workspace.id == workspaceId);
      if (index != -1) {
        _workspaces[index] = updatedWorkspace;
      }

      if (_currentWorkspace?.id == workspaceId) {
        _currentWorkspace = updatedWorkspace;
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWorkspaceById(int workspaceId) async {
    try {
      await _workspaceService.deleteWorkspace(workspaceId: workspaceId);

      final wasCurrentWorkspace = _currentWorkspace?.id == workspaceId;
      _workspaces = _workspaces.where((workspace) => workspace.id != workspaceId).toList();

      if (_workspaces.isEmpty) {
        _currentWorkspace = null;
        _workspaceMembers = [];
        await _persistLastOpenedWorkspaceId(null);
      } else if (wasCurrentWorkspace) {
        _currentWorkspace = _workspaces.first;
        await _persistLastOpenedWorkspaceId(_currentWorkspace?.id);
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveWorkspaceById(int workspaceId) async {
    try {
      await _workspaceService.leaveWorkspace(workspaceId: workspaceId);

      final wasCurrentWorkspace = _currentWorkspace?.id == workspaceId;
      _workspaces = _workspaces.where((workspace) => workspace.id != workspaceId).toList();

      if (_workspaces.isEmpty) {
        _currentWorkspace = null;
        _workspaceMembers = [];
        await _persistLastOpenedWorkspaceId(null);
      } else if (wasCurrentWorkspace) {
        _currentWorkspace = _workspaces.first;
        await _persistLastOpenedWorkspaceId(_currentWorkspace?.id);
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> reorderMyWorkspaces({
    required int oldIndex,
    required int newIndex,
  }) async {
    if (_currentUserId == null) {
      return false;
    }

    final ownedWorkspaces = myWorkspaces.toList();
    if (ownedWorkspaces.length < 2) {
      return true;
    }

    if (oldIndex < 0 || oldIndex >= ownedWorkspaces.length) {
      return false;
    }

    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }

    if (targetIndex < 0 || targetIndex >= ownedWorkspaces.length) {
      return false;
    }

    final previousWorkspaces = List<Workspace>.from(_workspaces);

    final movedWorkspace = ownedWorkspaces.removeAt(oldIndex);
    ownedWorkspaces.insert(targetIndex, movedWorkspace);

    final reorderedOwnedIds = ownedWorkspaces.map((workspace) => workspace.id).toList();
    final ownedIterator = ownedWorkspaces.iterator;

    _workspaces = _workspaces.map((workspace) {
      if (workspace.ownerId == _currentUserId) {
        ownedIterator.moveNext();
        return ownedIterator.current;
      }
      return workspace;
    }).toList();

    if (_currentWorkspace != null) {
      final currentId = _currentWorkspace!.id;
      _currentWorkspace = _workspaces.firstWhere(
        (workspace) => workspace.id == currentId,
        orElse: () => _currentWorkspace!,
      );
    }

    notifyListeners();

    try {
      await _workspaceService.reorderWorkspaces(
        orderedWorkspaceIds: reorderedOwnedIds,
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _workspaces = previousWorkspaces;
      if (_currentWorkspace != null) {
        final currentId = _currentWorkspace!.id;
        _currentWorkspace = _workspaces.firstWhere(
          (workspace) => workspace.id == currentId,
          orElse: () => _currentWorkspace!,
        );
      }
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearState() {
    _workspaces = [];
    _currentWorkspace = null;
    _workspaceMembers = [];
    _errorMessage = null;
    _membersErrorMessage = null;
    _isLoading = false;
    _isMembersLoading = false;
    _currentUserId = null;
    notifyListeners();
  }

  Workspace? _findFirstOwnedWorkspace() {
    if (_currentUserId == null) {
      return null;
    }

    for (final workspace in _workspaces) {
      if (workspace.ownerId == _currentUserId) {
        return workspace;
      }
    }

    return null;
  }

  String? get _lastOpenedWorkspaceStorageKey {
    if (_currentUserId == null) {
      return null;
    }
    return 'last_opened_workspace_id_$_currentUserId';
  }

  Future<int?> _readLastOpenedWorkspaceId() async {
    final key = _lastOpenedWorkspaceStorageKey;
    if (key == null) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<void> _persistLastOpenedWorkspaceId(int? workspaceId) async {
    final key = _lastOpenedWorkspaceStorageKey;
    if (key == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (workspaceId == null) {
      await prefs.remove(key);
      return;
    }

    await prefs.setInt(key, workspaceId);
  }
}
