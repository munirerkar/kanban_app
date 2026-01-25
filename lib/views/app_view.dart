import 'package:flutter/material.dart';
import 'package:kanban_project/views/task_detail_view.dart';
import 'package:provider/provider.dart';
import '../models/task_status.dart';
import '../models/user_model.dart';
import '../viewmodels/task_view_model.dart';
import 'package:intl/intl.dart';
import '../viewmodels/user_view_model.dart';
import '../widgets/kanban_app_bar.dart';
import '../widgets/kanban_bottom_bar.dart';
import '../widgets/task_column.dart';
import 'add_task_dialog.dart';

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
      context.read<TaskViewModel>().fetchTasks();
      context.read<UserViewModel>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          final bool isDetailOpen = taskViewModel.openedTask != null;

          return Scaffold(
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
            bottomNavigationBar: const KanbanBottomBar(),

            // Ekleme butonu
            floatingActionButton: (isDetailOpen || taskViewModel.isSelectionMode)
                ? null
                : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddTaskDialog(),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }
}




