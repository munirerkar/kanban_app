import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../views/settings_view.dart';
import '../views/task_form_dialog.dart';

class KanbanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KanbanAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final taskViewModel = context.watch<TaskViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: taskViewModel.isSelectionMode
          ? Colors.grey[900]
          : theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      leading: _buildLeading(context, taskViewModel),
      title: _buildTitle(context, taskViewModel),
      actions: _buildActions(context, taskViewModel),
      bottom: TabBar(
        onTap: (index) {
          if (taskViewModel.openedTask != null) {
            taskViewModel.setOpenedTask(null);
          }
        },
        isScrollable: false,
        indicatorColor: theme.colorScheme.onPrimary,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          _buildTabItem(l10n.appBarBacklog, taskViewModel.getTasksByStatus(TaskStatus.BACKLOG).length, theme),
          _buildTabItem(l10n.appBarToDo, taskViewModel.getTasksByStatus(TaskStatus.TODO).length, theme),
          _buildTabItem(l10n.appBarInProgress, taskViewModel.getTasksByStatus(TaskStatus.IN_PROGRESS).length, theme),
          _buildTabItem(l10n.appBarDone, taskViewModel.getTasksByStatus(TaskStatus.DONE).length, theme),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int count, ThemeData theme) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.visible, softWrap: false)),
          if (count > 0) ...[
            const SizedBox(width: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("$count", style: TextStyle(fontSize: 10, color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, TaskViewModel viewModel) {
    if (viewModel.openedTask != null) {
      return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => viewModel.setOpenedTask(null));
    } else if (viewModel.isSelectionMode || viewModel.isSearchMode) {
      return IconButton(icon: const Icon(Icons.close), onPressed: () {
          viewModel.isSearchMode ? viewModel.toggleSearchMode(false) : viewModel.toggleSelectionMode(false);
      });
    }
    return null;
  }

  Widget _buildTitle(BuildContext context, TaskViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    if (viewModel.isSearchMode) {
      return TextField(
        onChanged: (value) => viewModel.setSearchQuery(value),
        autofocus: true,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        cursorColor: Theme.of(context).colorScheme.onPrimary,
        decoration: InputDecoration(
          hintText: l10n.searchHint, // Use localized hint text
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
          border: InputBorder.none,
        ),
      );
    } else if (viewModel.openedTask != null) {
      return Text(l10n.appBarTaskDetails);
    } else if (viewModel.isSelectionMode) {
      return Text(l10n.appBarNSelected(viewModel.selectedTaskIds.length));
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/kanban_logo.png', height: 60, width: 60, fit: BoxFit.contain),
          Text("KANBAN", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w400, fontSize: 30, letterSpacing: 1.2)),
        ],
      );
    }
  }

  List<Widget> _buildActions(BuildContext context, TaskViewModel viewModel) {
    if (viewModel.isSearchMode) {
      return []; // Arama modunda aksiyon butonu olmasın
    } else if (viewModel.openedTask != null) {
      return [
        IconButton(icon: const Icon(Icons.edit), onPressed: () => showDialog(context: context, builder: (context) => TaskFormDialog(taskToEdit: viewModel.openedTask))),
      ];
    } else if (viewModel.isSelectionMode) {
      return [
        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async => await viewModel.deleteSelectedTasks(context)),
      ];
    } else {
      return [
        IconButton(icon: const Icon(Icons.search), onPressed: () => viewModel.toggleSearchMode(true)),
        IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsView()))),
      ];
    }
  }
}
