import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../views/task_form_dialog.dart';

class KanbanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KanbanAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight); // TabBar yüksekliği dahil

  @override
  Widget build(BuildContext context) {
    // ViewModel'i burada dinliyoruz, AppView kirlenmiyor
    final taskViewModel = context.watch<TaskViewModel>();
    final theme = Theme.of(context);
    final bool isDetailOpen = taskViewModel.openedTask != null;
    final bool isSelectionMode = taskViewModel.isSelectionMode;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      // RENK AYARI
      backgroundColor: isSelectionMode ? Colors.grey[900] : theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary, // AppBar üzerindeki tüm ikon ve metinlerin varsayılan rengi

      // SOL TARAFTAKİ BUTON (Leading)
      leading: _buildLeading(context, taskViewModel, isDetailOpen, isSelectionMode),

      // BAŞLIK (Title)
      title: _buildTitle(context, taskViewModel, isDetailOpen, isSelectionMode),

      // SAĞDAKİ BUTONLAR (Actions)
      actions: _buildActions(context, taskViewModel, isDetailOpen, isSelectionMode),

      // TAB BAR
      bottom: TabBar(
        onTap: (index) {
          if (isDetailOpen) {
            // Eğer detay açıksa, kapat (null yap).
            // Böylece AppView ekranı tekrar TabBarView'a (Listelere) çevirecek.
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

  // --- YARDIMCI METOTLAR ---

  Widget _buildTabItem(String title, int count, ThemeData theme) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, TaskViewModel viewModel, bool isDetail, bool isSelection) {
    if (isDetail) {
      return IconButton(
        icon: const Icon(Icons.arrow_back), // Renk temadan otomatik gelecek
        onPressed: () => viewModel.setOpenedTask(null), // Detayı kapat
      );
    } else if (isSelection) {
      return IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => viewModel.toggleSelectionMode(false), // Seçimi iptal et
      );
    }
    return null;
  }

  Widget _buildTitle(BuildContext context, TaskViewModel viewModel, bool isDetail, bool isSelection) {
    final l10n = AppLocalizations.of(context)!;
    if (isDetail) {
      return Text(l10n.appBarTaskDetails);
    } else if (isSelection) {
      return Text(l10n.appBarNSelected(viewModel.selectedTaskIds.length));
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/kanban_logo.png',
            height: 60,
            width: 60,
            fit: BoxFit.contain,
          ),
           Text(
              "KANBAN",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w400,
                fontSize: 30,
                letterSpacing: 1.2,)
          ),
        ],
      );
    }
  }

  List<Widget> _buildActions(BuildContext context, TaskViewModel viewModel, bool isDetail, bool isSelection) {
    final l10n = AppLocalizations.of(context)!;
    if (isDetail) {
      // Detay modunda: DÜZENLE (Edit) butonu
      return [
        IconButton(
          icon: const Icon(Icons.edit), // Renk temadan otomatik gelecek
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => TaskFormDialog(taskToEdit: viewModel.openedTask),
            );
          },
        )
      ];
    } else if (isSelection) {
      // Seçim modunda: ÇÖP KUTUSU (Sil) butonu
      return [
        IconButton(
          icon: const Icon(Icons.delete_outline), // Renk temadan otomatik gelecek
          onPressed: () async {
            // Emin misin sorusu ve silme işlemi
            await viewModel.deleteSelectedTasks(context);
          },
        )
      ];
    } else {
      // Normal modda: Arama ve Ayarlar
      return [
        IconButton(icon: const Icon(Icons.search), onPressed: () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.searchComingSoon)));}),
        IconButton(icon: const Icon(Icons.settings), onPressed: () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsComingSoon)));}),
      ];
    }
  }
}
