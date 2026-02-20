import 'package:flutter/material.dart';
import 'package:kanban_project/models/user_model.dart';
import 'package:kanban_project/models/workspace_model.dart';
import 'package:kanban_project/services/workspace_service.dart';

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

  List<Workspace> get workspaces => _workspaces;
  Workspace? get currentWorkspace => _currentWorkspace;
  List<User> get workspaceMembers => _workspaceMembers;
  bool get isLoading => _isLoading;
  bool get isMembersLoading => _isMembersLoading;
  String? get errorMessage => _errorMessage;
  String? get membersErrorMessage => _membersErrorMessage;

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

        _currentWorkspace = hasCurrent
            ? _workspaces.firstWhere((workspace) => workspace.id == currentId)
            : _workspaces.first;
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

  void selectWorkspace(Workspace workspace) {
    if (_currentWorkspace?.id == workspace.id) {
      return;
    }

    _currentWorkspace = workspace;
    _workspaceMembers = [];
    _membersErrorMessage = null;
    notifyListeners();
  }

  void clearState() {
    _workspaces = [];
    _currentWorkspace = null;
    _workspaceMembers = [];
    _errorMessage = null;
    _membersErrorMessage = null;
    _isLoading = false;
    _isMembersLoading = false;
    notifyListeners();
  }
}
