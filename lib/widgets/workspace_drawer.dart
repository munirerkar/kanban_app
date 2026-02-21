import 'package:flutter/material.dart';
import 'package:kanban_project/l10n/app_localizations.dart';
import 'package:kanban_project/models/workspace_model.dart';
import 'package:kanban_project/viewmodels/workspace_view_model.dart';
import 'package:provider/provider.dart';

import 'workspace_action_dialogs.dart';

class WorkspaceDrawer extends StatelessWidget {
  const WorkspaceDrawer({
    required this.onWorkspaceSelected,
    required this.onWorkspaceUpdated,
    super.key,
  });

  final Future<void> Function(Workspace workspace) onWorkspaceSelected;
  final Future<void> Function() onWorkspaceUpdated;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Consumer<WorkspaceViewModel>(
          builder: (context, workspaceViewModel, child) {
            final workspaces = workspaceViewModel.workspaces;
            final myWorkspaces = workspaceViewModel.myWorkspaces;
            final sharedWorkspaces = workspaceViewModel.sharedWorkspaces;
            final Map<int, List<Workspace>> sharedWorkspacesByOwner =
                <int, List<Workspace>>{};

            for (final workspace in sharedWorkspaces) {
              sharedWorkspacesByOwner
                  .putIfAbsent(workspace.ownerId, () => <Workspace>[])
                  .add(workspace);
            }

            Future<void> handleReorder(int oldIndex, int newIndex) async {
              final success = await workspaceViewModel.reorderMyWorkspaces(
                oldIndex: oldIndex,
                newIndex: newIndex,
              );

              if (!context.mounted) {
                return;
              }

              if (!success) {
                final error = workspaceViewModel.errorMessage;
                if (error != null && error.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              }
            }

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
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                      children: [
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(l10n.workspaceDrawerMyWorkspaces),
                          children: [
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              buildDefaultDragHandles: false,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: myWorkspaces.length,
                              onReorder: handleReorder,
                              itemBuilder: (context, index) {
                                final workspace = myWorkspaces[index];
                                return ReorderableDragStartListener(
                                  key: ValueKey('owned_workspace_${workspace.id}'),
                                  index: index,
                                  child: _WorkspaceTile(
                                    workspace: workspace,
                                    onTap: () => onWorkspaceSelected(workspace),
                                    onOpenActions: () => WorkspaceActionDialogs.showWorkspaceActionsSheet(
                                      context: context,
                                      workspace: workspace,
                                      onWorkspaceUpdated: onWorkspaceUpdated,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ...sharedWorkspacesByOwner.entries.map(
                          (entry) => _SharedOwnerGroupTile(
                            ownerWorkspaces: entry.value,
                            onWorkspaceTap: (workspace) => onWorkspaceSelected(workspace),
                            onWorkspaceActionsTap: (workspace) => WorkspaceActionDialogs.showWorkspaceActionsSheet(
                              context: context,
                              workspace: workspace,
                              onWorkspaceUpdated: onWorkspaceUpdated,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WorkspaceTile extends StatelessWidget {
  const _WorkspaceTile({
    required this.workspace,
    required this.onTap,
    required this.onOpenActions,
    super.key,
  });

  final Workspace workspace;
  final Future<void> Function() onTap;
  final Future<void> Function() onOpenActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentWorkspace = context.watch<WorkspaceViewModel>().currentWorkspace;
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onOpenActions,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _SharedOwnerGroupTile extends StatelessWidget {
  const _SharedOwnerGroupTile({
    required this.ownerWorkspaces,
    required this.onWorkspaceTap,
    required this.onWorkspaceActionsTap,
  });

  final List<Workspace> ownerWorkspaces;
  final Future<void> Function(Workspace workspace) onWorkspaceTap;
  final Future<void> Function(Workspace workspace) onWorkspaceActionsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ownerName = ownerWorkspaces.first.ownerName?.trim().isNotEmpty == true
        ? ownerWorkspaces.first.ownerName!.trim()
        : l10n.profileUnknownName;

    final avatarLetter = ownerName.characters.first.toUpperCase();

    return ExpansionTile(
      title: Row(
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(
              avatarLetter,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ownerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: ownerWorkspaces
          .map(
            (workspace) => _WorkspaceTile(
              key: ValueKey('shared_workspace_${workspace.id}'),
              workspace: workspace,
              onTap: () => onWorkspaceTap(workspace),
              onOpenActions: () => onWorkspaceActionsTap(workspace),
            ),
          )
          .toList(),
    );
  }
}
