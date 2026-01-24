import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_status.dart';
import '../models/user_model.dart';
import '../viewmodels/task_view_model.dart';
import 'package:intl/intl.dart';
import '../viewmodels/user_view_model.dart';
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
      context.read<UserViewModel>().fetchUsers();
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
    return Consumer2<TaskViewModel, UserViewModel>(
      builder: (context, viewModel, userViewModel, child) {
        if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
        if (viewModel.errorMessage != null) return Center(child: Text(viewModel.errorMessage!));

        final tasks = viewModel.getTasksByStatus(status);
        final allUsers = userViewModel.users;

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

              // GÖREVE ATANAN KULLANICILARI BULMA
              // Görevin içindeki ID'lerle eşleşen kullanıcıları listele
              final taskAssignees = allUsers
                  .where((user) => task.assigneeIds.contains(user.id))
                  .toList();
              return Dismissible(
                  key: Key(task.id.toString()), // Her kartın benzersiz anahtarı
                  direction: DismissDirection.horizontal, // Hem sağa hem sola izin ver

                  // --- ARKAPLAN TASARIMLARI ---
                  // Sola Kaydırınca (Geri Gitme Rengi - Turuncu/Kırmızı)
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.orange[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.undo, color: Colors.white, size: 30),
                  ),

                  // Sağa Kaydırınca (İleri Gitme Rengi - Yeşil)
                  secondaryBackground: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                  ),

                  // --- MANTIK KISMI ---
                  confirmDismiss: (direction) async {
                    TaskStatus? newStatus;

                    // Yön Kontrolü: Hangi statüdeyiz, nereye gidiyoruz?
                    if (direction == DismissDirection.endToStart) {
                      // SAĞA KAYDIRMA (İLERİ GİT) ->
                      if (task.status == TaskStatus.BACKLOG) newStatus = TaskStatus.TODO;
                      else if (task.status == TaskStatus.TODO) newStatus = TaskStatus.IN_PROGRESS;
                      else if (task.status == TaskStatus.IN_PROGRESS) newStatus = TaskStatus.DONE;
                    } else {
                      // SOLA KAYDIRMA (GERİ GİT) <-
                      if (task.status == TaskStatus.DONE) newStatus = TaskStatus.IN_PROGRESS;
                      else if (task.status == TaskStatus.IN_PROGRESS) newStatus = TaskStatus.TODO;
                      else if (task.status == TaskStatus.TODO) newStatus = TaskStatus.BACKLOG;
                    }

                    if (newStatus != null) {
                      context.read<TaskViewModel>().updateStatus(task, newStatus);
                      return false;
                    }
                    return false; // Değişiklik yoksa bir şey yapma
                  },
                  child: Container(
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
                            taskAssignees.isEmpty
                                ? Icon(Icons.person_off_outlined, size: 18, color: Colors.grey[300])
                                : SizedBox(
                              height: 24, // Avatar satırının yüksekliği
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true, // Sadece içeriği kadar yer kapla
                                itemCount: taskAssignees.length > 3 ? 4 : taskAssignees.length, // Max 3 kişi + (+1) göster
                                itemBuilder: (context, userIndex) {
                                  // Eğer 3'ten fazla kişi varsa 4. balonda "+2" gibi sayı göster
                                  if (userIndex == 3) {
                                    return CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        "+${taskAssignees.length - 3}",
                                        style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }

                                  final user = taskAssignees[userIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4.0), // Avatarlar arası boşluk
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty)
                                          ? NetworkImage(user.profilePictureUrl!)
                                          : null,
                                      child: (user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty)
                                          ? const Icon(Icons.person, size: 14, color: Colors.grey)
                                          : null,
                                    ),
                                  );
                                },
                              ),
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
                  )
              );
            },
        );
      },
    );
  }
}