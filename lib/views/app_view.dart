import 'package:flutter/material.dart';
import 'package:kanban_project/views/task_detail_view.dart';
import 'package:provider/provider.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../viewmodels/user_view_model.dart';
import '../widgets/kanban_app_bar.dart';
import '../widgets/kanban_bottom_bar.dart';
import '../widgets/task_column.dart';
import 'task_form_dialog.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    // Verileri çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().fetchTasks(context);
      context.read<UserViewModel>().fetchUsers();
    });
  }

  void _goHome() {
    // ViewModel'e erişip detay sayfasını kapat
    context.read<TaskViewModel>().setOpenedTask(null);

    // TabController'a erişip ilk sekmeye git
    final tabController = DefaultTabController.of(context);
    if (tabController.index != 0) {
      tabController.animateTo(0);
    }
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

            // Geri tuşuna basılınca burası çalışır
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return; // Zaten işlem yapıldıysa karışma

              // 1. DURUM: Detay sayfası açıksa
              if (taskViewModel.openedTask != null) {
                // Detay görünümünü kapat (Panoya geri dön)
                taskViewModel.setOpenedTask(null);
              }
              // 2. DURUM: Detay kapalıysa (Ana ekrandaysa)
              else {
                // Hiçbir şey yapma (Uygulama kapanmaz)
              }
            },

            child: Scaffold(
            // APPBAR
            appBar: const KanbanAppBar(),

            // BODY (Detay mı, Tablo mu?)
            body: isDetailOpen
                ? TaskDetailView(task: taskViewModel.openedTask!)
                : const TabBarView(
              children: [
                TaskColumn(status: TaskStatus.BACKLOG),
                TaskColumn(status: TaskStatus.TODO),
                TaskColumn(status: TaskStatus.IN_PROGRESS),
                TaskColumn(status: TaskStatus.DONE),
              ],
            ),

            // BOTTOMBAR
            bottomNavigationBar: KanbanBottomBar(onHomePressed: _goHome), // Pass the callback here

            // Ekleme butonu
            floatingActionButton: (isDetailOpen || taskViewModel.isSelectionMode)
                ? null
                : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const TaskFormDialog(),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary, // Use color from theme
              elevation: 4,
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary), // Use contrasting color from theme
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),);

        },
      ),
    );
  }
}
