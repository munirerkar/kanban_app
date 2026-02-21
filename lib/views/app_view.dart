import 'package:flutter/material.dart';
import 'package:kanban_project/l10n/app_localizations.dart';
import 'package:kanban_project/models/workspace_model.dart';
import 'package:kanban_project/viewmodels/auth_view_model.dart';
import 'package:kanban_project/viewmodels/workspace_view_model.dart';
import 'package:kanban_project/views/profile_view.dart';
import 'package:kanban_project/views/task_detail_view.dart';
import 'package:kanban_project/widgets/dynamic_app_bar.dart';
import 'package:kanban_project/widgets/kanban_bottom_bar.dart';
import 'package:kanban_project/widgets/task_column.dart';
import 'package:kanban_project/widgets/task_form_dialog.dart';
import 'package:kanban_project/widgets/workspace_drawer.dart';
import 'package:provider/provider.dart';

import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = context.read<AuthViewModel>();
      final workspaceViewModel = context.read<WorkspaceViewModel>();
      final taskViewModel = context.read<TaskViewModel>();
      final l10n = AppLocalizations.of(context)!;

      await authViewModel.refreshCurrentUser();
      if (!mounted) return;

      workspaceViewModel.setCurrentUser(authViewModel.currentUser);

      await workspaceViewModel.fetchWorkspaces();
      if (!mounted) return;

      await workspaceViewModel.fetchWorkspaceMembers(
        workspaceViewModel.currentWorkspace?.id,
      );
      if (!mounted) return;

      await taskViewModel.setCurrentWorkspaceId(
        workspaceViewModel.currentWorkspace?.id,
        fetch: true,
        l10n: l10n,
      );
    });
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _syncCurrentWorkspaceTasks(BuildContext context) async {
    final workspaceViewModel = context.read<WorkspaceViewModel>();
    final taskViewModel = context.read<TaskViewModel>();
    final l10n = AppLocalizations.of(context)!;

    await workspaceViewModel.fetchWorkspaceMembers(
      workspaceViewModel.currentWorkspace?.id,
    );
    if (!context.mounted) {
      return;
    }

    await taskViewModel.setCurrentWorkspaceId(
      workspaceViewModel.currentWorkspace?.id,
      fetch: true,
      l10n: l10n,
    );
  }

  Future<void> _handleWorkspaceSelected(Workspace workspace) async {
    final workspaceViewModel = context.read<WorkspaceViewModel>();

    await workspaceViewModel.selectWorkspace(workspace);
    if (!mounted) {
      return;
    }

    await _syncCurrentWorkspaceTasks(context);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  Future<void> _handleWorkspaceUpdated() async {
    await _syncCurrentWorkspaceTasks(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          final bool isDetailOpen = taskViewModel.openedTask != null;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                return;
              }

              if (_selectedIndex == 1) {
                _selectTab(0);
                return;
              }

              if (taskViewModel.openedTask != null) {
                taskViewModel.setOpenedTask(null);
              }
            },
            child: Scaffold(
              appBar: DynamicAppBar(selectedIndex: _selectedIndex),
              drawer: WorkspaceDrawer(
                onWorkspaceSelected: _handleWorkspaceSelected,
                onWorkspaceUpdated: _handleWorkspaceUpdated,
              ),
              body: IndexedStack(
                index: _selectedIndex,
                children: [
                  _TasksView(isDetailOpen: isDetailOpen),
                  const ProfileView(),
                ],
              ),
              bottomNavigationBar: KanbanBottomBar(
                selectedIndex: _selectedIndex,
                onTasksPressed: () => _selectTab(0),
                onProfilePressed: () => _selectTab(1),
              ),
              floatingActionButton: (_selectedIndex == 0 && !isDetailOpen)
                  ? (taskViewModel.isSelectionMode
                      ? FloatingActionButton(
                          onPressed: () async {
                            final l10n = AppLocalizations.of(context)!;
                            final bool? confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(l10n.deleteConfirmationTitle),
                                  content: Text(
                                    l10n.deleteConfirmationMessage(
                                      taskViewModel.selectedTaskIds.length,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(l10n.cancelButton),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(
                                        l10n.deleteButton,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed == true) {
                              if (!context.mounted) {
                                return;
                              }
                              await taskViewModel.deleteSelectedTasks(context);
                            }
                          },
                          backgroundColor: Theme.of(context).colorScheme.error,
                          child: const Icon(Icons.delete_outline),
                        )
                      : FloatingActionButton(
                          onPressed: () async {
                            final workspaceViewModel = context.read<WorkspaceViewModel>();
                            await workspaceViewModel.fetchWorkspaceMembers(
                              workspaceViewModel.currentWorkspace?.id,
                            );
                            if (!context.mounted) return;

                            showDialog(
                              context: context,
                              builder: (context) => const TaskFormDialog(),
                            );
                          },
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 4,
                          child: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ))
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
          );
        },
      ),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView({required this.isDetailOpen});

  final bool isDetailOpen;

  @override
  Widget build(BuildContext context) {
    final taskViewModel = context.watch<TaskViewModel>();

    if (isDetailOpen && taskViewModel.openedTask != null) {
      return TaskDetailView(task: taskViewModel.openedTask!);
    }

    return const TabBarView(
      children: [
        TaskColumn(status: TaskStatus.BACKLOG),
        TaskColumn(status: TaskStatus.TODO),
        TaskColumn(status: TaskStatus.IN_PROGRESS),
        TaskColumn(status: TaskStatus.DONE),
      ],
    );
  }
}
