import 'package:flutter/material.dart';
import 'package:kanban_project/l10n/app_localizations.dart';
import 'package:kanban_project/models/workspace_model.dart';
import 'package:kanban_project/viewmodels/workspace_view_model.dart';
import 'package:provider/provider.dart';

class WorkspaceActionDialogs {
  const WorkspaceActionDialogs._();

  static Future<void> showWorkspaceActionsSheet({
    required BuildContext context,
    required Workspace workspace,
    Future<void> Function()? onWorkspaceUpdated,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final workspaceViewModel = context.read<WorkspaceViewModel>();
    final isOwner = workspaceViewModel.isOwnedByCurrentUser(workspace);

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwner) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.workspaceActionEdit),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showRenameWorkspaceDialog(
                      context: context,
                      workspace: workspace,
                      onWorkspaceUpdated: onWorkspaceUpdated,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.workspaceActionDelete),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    confirmAndDeleteWorkspace(
                      context: context,
                      workspace: workspace,
                      onWorkspaceUpdated: onWorkspaceUpdated,
                    );
                  },
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: Text(l10n.workspaceActionLeave),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    confirmAndLeaveWorkspace(
                      context: context,
                      workspace: workspace,
                      onWorkspaceUpdated: onWorkspaceUpdated,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showRenameWorkspaceDialog({
    required BuildContext context,
    required Workspace workspace,
    Future<void> Function()? onWorkspaceUpdated,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final workspaceViewModel = context.read<WorkspaceViewModel>();
    final controller = TextEditingController(text: workspace.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.workspaceActionEdit),
          content: TextField(
            controller: controller,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: l10n.formTitleHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: Text(l10n.formSaveChanges),
            ),
          ],
        );
      },
    );

    final trimmedName = newName?.trim();
    if (trimmedName == null || trimmedName.isEmpty || trimmedName == workspace.name) {
      return;
    }

    final success = await workspaceViewModel.updateWorkspaceName(
      workspace.id.toString(),
      trimmedName,
    );

    if (!context.mounted) {
      return;
    }

    if (!success && workspaceViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(workspaceViewModel.errorMessage!)),
      );
      return;
    }

    if (success && onWorkspaceUpdated != null) {
      await onWorkspaceUpdated();
    }
  }

  static Future<void> confirmAndDeleteWorkspace({
    required BuildContext context,
    required Workspace workspace,
    Future<void> Function()? onWorkspaceUpdated,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final workspaceViewModel = context.read<WorkspaceViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.workspaceActionDelete),
          content: Text(l10n.workspaceDeleteConfirmationMessage(workspace.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.workspaceActionDelete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await workspaceViewModel.deleteWorkspaceById(workspace.id);
    if (!context.mounted) {
      return;
    }

    if (!success && workspaceViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(workspaceViewModel.errorMessage!)),
      );
      return;
    }

    if (success && onWorkspaceUpdated != null) {
      await onWorkspaceUpdated();
    }
  }

  static Future<void> confirmAndLeaveWorkspace({
    required BuildContext context,
    required Workspace workspace,
    Future<void> Function()? onWorkspaceUpdated,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final workspaceViewModel = context.read<WorkspaceViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.workspaceActionLeave),
          content: Text(l10n.workspaceLeaveConfirmationMessage(workspace.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.workspaceActionLeave),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await workspaceViewModel.leaveWorkspaceById(workspace.id);
    if (!context.mounted) {
      return;
    }

    if (!success && workspaceViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(workspaceViewModel.errorMessage!)),
      );
      return;
    }

    if (success && onWorkspaceUpdated != null) {
      await onWorkspaceUpdated();
    }
  }
}
