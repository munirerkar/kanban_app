import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../viewmodels/task_view_model.dart';
import '../viewmodels/user_view_model.dart';

class TaskColumn extends StatelessWidget {
  final TaskStatus status;

  const TaskColumn({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel, UserViewModel>(
      builder: (context, taskViewModel, userViewModel, child) {

        final tasks = taskViewModel.getTasksByStatus(status);

        return RefreshIndicator(
          onRefresh: () async {
            // Aşağı çekince Backend'den verileri tekrar çek
            await taskViewModel.fetchTasks();
          },
          // Renk ayarı (Opsiyonel)
          color: Theme
              .of(context)
              .primaryColor,

          child: _buildBody(context, taskViewModel, userViewModel, tasks),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TaskViewModel taskViewModel, UserViewModel userViewModel,List<Task> tasks) {
    // Yükleniyorsa
    if (taskViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // HATA VARSA
    if (taskViewModel.errorMessage != null) {
      // Hata ekranını da ListView içine alıyoruz ki "Aşağı Çekilebilsin"
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        // 👈 KRİTİK NOKTA: Boşken bile kaydırmaya izin ver
        children: [
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * 0.3), // Ortalamak için boşluk
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 10),
                Text(
                  "Connection Error!",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  taskViewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      );
    }
    // LİSTE BOŞSA
    if (tasks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        // 👈 Boşken bile çekilebilsin
        children: [
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 48,
                    color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text(
                  "No tasks in ${status.name}",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        // TARİH FORMATLAMA İŞLEMİ
        String formattedDate = task.deadline;
        try {
          DateTime parsedDate = DateTime.parse(
              task.deadline); // String'i tarihe çevir
          formattedDate = DateFormat("d MMM").format(
              parsedDate); // "17 Feb" formatına çevir
        } catch (e) {
          // Eğer tarih boşsa veya bozuksa olduğu gibi kalsın
        }

        // GÖREVE ATANAN KULLANICILARI BULMA
        // Görevin içindeki ID'lerle eşleşen kullanıcıları listele
        final taskAssignees = userViewModel.users
            .where((user) => task.assigneeIds.contains(user.id))
            .toList();

        final isSelected = taskViewModel.selectedTaskIds.contains(task.id);

        return Dismissible(
            key: Key(task.id.toString()),
            // Her kartın benzersiz anahtarı
            direction: taskViewModel.isSelectionMode
                ? DismissDirection.none
                : DismissDirection.horizontal,

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
              child: const Icon(
                  Icons.arrow_forward, color: Colors.white, size: 30),
            ),

            // --- MANTIK KISMI ---
            confirmDismiss: (direction) async {
              TaskStatus? newStatus;

              // Yön Kontrolü: Hangi statüdeyiz, nereye gidiyoruz?
              if (direction == DismissDirection.endToStart) {
                // SAĞA KAYDIRMA (İLERİ GİT) ->
                if (task.status == TaskStatus.BACKLOG)
                  newStatus = TaskStatus.TODO;
                else if (task.status == TaskStatus.TODO)
                  newStatus = TaskStatus.IN_PROGRESS;
                else if (task.status == TaskStatus.IN_PROGRESS)
                  newStatus = TaskStatus.DONE;
              } else {
                // SOLA KAYDIRMA (GERİ GİT) <-
                if (task.status == TaskStatus.DONE)
                  newStatus = TaskStatus.IN_PROGRESS;
                else if (task.status == TaskStatus.IN_PROGRESS)
                  newStatus = TaskStatus.TODO;
                else if (task.status == TaskStatus.TODO)
                  newStatus = TaskStatus.BACKLOG;
              }

              if (newStatus != null) {
                context.read<TaskViewModel>().updateStatus(task, newStatus);
                return false;
              }
              return false; // Değişiklik yoksa bir şey yapma
            },
            child: GestureDetector(
              // 👇 UZUN BASINCA: Seçim modunu başlat
                onLongPress: () {
                  taskViewModel.toggleSelectionMode(true);
                  taskViewModel.toggleTaskSelection(task.id!);
                },
                // 👇 TIKLAYINCA:
                onTap: () {
                  if (taskViewModel.isSelectionMode) {
                    taskViewModel.toggleTaskSelection(task.id!);
                  } else {
                    // ViewModel'e görevi gönder
                    context.read<TaskViewModel>().setOpenedTask(task);
                  }
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  // Renk değişimi animasyonu
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.1) : Theme
                        .of(context)
                        .colorScheme
                        .surface,
                    border: isSelected ? Border.all(
                        color: Colors.blue, width: 2) : null,
                    // Seçiliyse mavi çerçeve
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [] : [
                      // Seçiliyse gölgeyi kaldır (düz görünsün)
                      BoxShadow(color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const
                          Offset(0, 2)
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
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Açıklama
                      Text(
                        task.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme
                            .of(context)
                            .colorScheme
                            .onSurfaceVariant, fontSize: 13),
                      ),
                      const SizedBox(height: 12),

                      // Alt Satır: Avatar ve Tarih
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          taskAssignees.isEmpty
                              ? Icon(Icons.person_off_outlined, size: 18,
                              color: Colors.grey[300])
                              : SizedBox(
                            height: 24, // Avatar satırının yüksekliği
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              // Sadece içeriği kadar yer kapla
                              itemCount: taskAssignees.length > 3
                                  ? 4
                                  : taskAssignees.length,
                              // Max 3 kişi + (+1) göster
                              itemBuilder: (context, userIndex) {
                                // Eğer 3'ten fazla kişi varsa 4. balonda "+2" gibi sayı göster
                                if (userIndex == 3) {
                                  return CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.grey[300],
                                    child: Text(
                                      "+${taskAssignees.length - 3}",
                                      style: const TextStyle(fontSize: 10,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }

                                final user = taskAssignees[userIndex];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  // Avatarlar arası boşluk
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: (user.profilePictureUrl !=
                                        null &&
                                        user.profilePictureUrl!.isNotEmpty)
                                        ? NetworkImage(user.profilePictureUrl!)
                                        : null,
                                    child: (user.profilePictureUrl == null ||
                                        user.profilePictureUrl!.isEmpty)
                                        ? const Icon(Icons.person, size: 14,
                                        color: Colors.grey)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Tarih Kutucuğu
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, size: 14,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
            )
        );
      },
    );
  }
}