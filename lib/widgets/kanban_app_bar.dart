import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final bool isDetailOpen = taskViewModel.openedTask != null;
    final bool isSelectionMode = taskViewModel.isSelectionMode;

    return AppBar(
      // RENK AYARI
      backgroundColor: isSelectionMode ? Colors.grey[900] : Theme.of(context).colorScheme.primary,

      // SOL TARAFTAKİ BUTON (Leading)
      leading: _buildLeading(context, taskViewModel, isDetailOpen, isSelectionMode),

      // BAŞLIK (Title)
      title: _buildTitle(taskViewModel, isDetailOpen, isSelectionMode),

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
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          _buildTabItem("Backlog", taskViewModel.getTasksByStatus(TaskStatus.BACKLOG).length),
          _buildTabItem("To Do", taskViewModel.getTasksByStatus(TaskStatus.TODO).length),
          _buildTabItem("Progress", taskViewModel.getTasksByStatus(TaskStatus.IN_PROGRESS).length),
          _buildTabItem("Done", taskViewModel.getTasksByStatus(TaskStatus.DONE).length),
        ],
      ),
    );
  }

  // --- YARDIMCI METOTLAR ---

  Widget _buildTabItem(String title, int count) {
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
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
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
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => viewModel.setOpenedTask(null), // Detayı kapat
      );
    } else if (isSelection) {
      return IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => viewModel.toggleSelectionMode(false), // Seçimi iptal et
      );
    }
    return null; // Normal modda bir şey yok (varsa logo koyabilirsin)
  }

  Widget _buildTitle(TaskViewModel viewModel, bool isDetail, bool isSelection) {
    if (isDetail) {
      return const Text("Task Details", style: TextStyle(color: Colors.white));
    } else if (isSelection) {
      return Text("${viewModel.selectedTaskIds.length} Selected", style: const TextStyle(color: Colors.white));
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
          const Text(
              "KANBAN",
              style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 30,
                letterSpacing: 1.2,)
          ),
        ],
      );
    }
  }

  List<Widget> _buildActions(BuildContext context, TaskViewModel viewModel, bool isDetail, bool isSelection) {
    if (isDetail) {
      // Detay modunda: DÜZENLE (Edit) butonu
      return [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
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
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: () async {
            // Emin misin sorusu ve silme işlemi
            await viewModel.deleteSelectedTasks();
          },
        )
      ];
    } else {
      // Normal modda: Arama ve Ayarlar
      return [
        IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Search mode coming soon!")));}),
        IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings mode coming soon!")));}),
      ];
    }
  }
}