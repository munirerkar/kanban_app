import 'package:flutter/material.dart';
import 'package:kanban_project/l10n/app_localizations.dart';
import 'package:kanban_project/viewmodels/auth_view_model.dart';
import 'package:kanban_project/viewmodels/workspace_view_model.dart';
import 'package:kanban_project/views/profile_view.dart';
import 'package:kanban_project/views/task_detail_view.dart';
import 'package:provider/provider.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../widgets/kanban_app_bar.dart';
import '../widgets/kanban_bottom_bar.dart';
import '../widgets/task_column.dart';
import '../widgets/task_form_dialog.dart';

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
    // Verileri çek
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = context.read<AuthViewModel>();
      final workspaceViewModel = context.read<WorkspaceViewModel>();
      final taskViewModel = context.read<TaskViewModel>();
      final l10n = AppLocalizations.of(context)!;

      await authViewModel.refreshCurrentUser();
      if (!mounted) return;

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

  PreferredSizeWidget _buildDynamicAppBar(BuildContext context) {
    if (_selectedIndex == 0) {
      return const KanbanAppBar();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Text(
        l10n.profileAccountTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWorkspaceDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Consumer<WorkspaceViewModel>(
          builder: (context, workspaceViewModel, child) {
            final workspaces = workspaceViewModel.workspaces;
            final currentWorkspace = workspaceViewModel.currentWorkspace;

            return Column(
              children: [
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Icon(
                        Icons.dashboard_customize_outlined,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.workspaceDrawerTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (workspaceViewModel.isLoading && workspaces.isEmpty)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (workspaces.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          workspaceViewModel.errorMessage ?? l10n.workspaceDrawerNoWorkspaces,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      child: ClipRect(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                          itemCount: workspaces.length,
                          itemBuilder: (context, index) {
                            final workspace = workspaces[index];
                            final isSelected = currentWorkspace?.id == workspace.id;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Material(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  selected: isSelected,
                                  title: Text(
                                    workspace.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: (workspace.description != null && workspace.description!.trim().isNotEmpty)
                                      ? Text(
                                          workspace.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                  onTap: () async {
                                    final workspaceViewModel = context.read<WorkspaceViewModel>();
                                    final taskViewModel = context.read<TaskViewModel>();
                                    final l10n = AppLocalizations.of(context)!;

                                    workspaceViewModel.selectWorkspace(workspace);
                                    await workspaceViewModel.fetchWorkspaceMembers(workspace.id);
                                    if (!context.mounted) return;

                                    await taskViewModel.setCurrentWorkspaceId(
                                      workspace.id,
                                      fetch: true,
                                      l10n: l10n,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
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
              appBar: _buildDynamicAppBar(context),
              drawer: _buildWorkspaceDrawer(context),
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
                                  content: Text(l10n.deleteConfirmationMessage(taskViewModel.selectedTaskIds.length)),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(l10n.cancelButton),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(
                                        l10n.deleteButton,
                                        style: TextStyle(color: Theme.of(context).colorScheme.error),
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
