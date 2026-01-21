import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import 'package:intl/intl.dart';
import 'add_task_dialog.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}


class _AppViewState extends State<AppView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Verileri çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().fetchTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomAppBar(),

      body: TabBarView(
        controller: _tabController,
        children: const [
          TaskColumn(status: TaskStatus.BACKLOG),
          TaskColumn(status: TaskStatus.TODO),
          TaskColumn(status: TaskStatus.IN_PROGRESS),
          TaskColumn(status: TaskStatus.DONE),
        ],
      ),

      // Ekleme butonu
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTaskDialog(),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  BottomAppBar _buildBottomAppBar() {
    return BottomAppBar(
      color: Theme.of(context).primaryColor,
      surfaceTintColor: Colors.white,
      elevation: 8.0,
      shape: const CircularNotchedRectangle(),
      height: 60,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 32),
              onPressed: () {
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
              },
              child: const Text(
                'Go to Word Ninja',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final viewModel = context.watch<TaskViewModel>();
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      toolbarHeight: 80.0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
        children: [
          Image.asset('assets/images/kanban_logo.png', height: 60),
          const Text(
            'KANBAN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 30,
              letterSpacing: 1.2,
            ),
          ),
        ],
        )
      ),

      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 28),
          onPressed: () {
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 28),
          onPressed: () {
          },
        ),
        const SizedBox(width: 8),
      ],

      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          _buildTabItem("Backlog", viewModel.getTasksByStatus(TaskStatus.BACKLOG).length),
          _buildTabItem("To Do", viewModel.getTasksByStatus(TaskStatus.TODO).length),
          _buildTabItem("Progress", viewModel.getTasksByStatus(TaskStatus.IN_PROGRESS).length),
          _buildTabItem("Done", viewModel.getTasksByStatus(TaskStatus.DONE).length),
        ],
      ),
    );
  }
}

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

// LİSTELEME WIDGET'I
class TaskColumn extends StatelessWidget {
  final TaskStatus status;
  const TaskColumn({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
        if (viewModel.errorMessage != null) return Center(child: Text(viewModel.errorMessage!));

        final tasks = viewModel.getTasksByStatus(status);

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No tasks in this area.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              // TARİH FORMATLAMA İŞLEMİ
              String formattedDate = task.deadline;
              try {
                DateTime parsedDate = DateTime.parse(task.deadline); // String'i tarihe çevir
                formattedDate = DateFormat("d MMM").format(parsedDate); // "17 Feb" formatına çevir
              } catch (e) {
                // Eğer tarih boşsa veya bozuksa olduğu gibi kalsın
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Açıklama
                    Text(
                      task.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Alt Satır: Avatar ve Tarih
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar (Şimdilik statik)
                        const CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
                        ),

                        // Tarih Kutucuğu
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
        );
      },
    );
  }
}