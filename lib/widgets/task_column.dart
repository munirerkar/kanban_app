import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
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

        final tasks = taskViewModel.getTasksByStatus(status, userViewModel.users); // Pass users to the filter

        return RefreshIndicator(
          onRefresh: () async {
            // Aşağı çekince Backend'den verileri tekrar çek
            await taskViewModel.fetchTasks(context);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 10),
                Text(
                  l10n.taskColumnConnectionError,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  taskViewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
                    color: theme.colorScheme.surfaceContainerHighest),
                const SizedBox(height: 10),
                Text(
                  l10n.taskColumnNoTasks(status.name),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ReorderableListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      buildDefaultDragHandles: false,

      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Material(
              elevation: 8, // Havaya kalkma gölgesi
              color: Colors.transparent, // Arkaplan şeffaf olsun ki bizim kartın rengi görünsün
              borderRadius: BorderRadius.circular(16), // KÖŞELERİ YUVARLA
              child: child,
            );
          },
          child: child,
        );
      },

      onReorder: (oldIndex, newIndex) {
        if (taskViewModel.isSearchMode) return; // Arama modunda sıralamaya izin verme
        if (oldIndex < newIndex) newIndex -= 1;
        taskViewModel.reorderLocalTasks(status, oldIndex, newIndex);
      },
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

        return Padding(
          key: Key(task.id.toString()), // Anahtar Padding widget'ına taşındı
          padding: const EdgeInsets.only(bottom: 12), // Kartlar arası dikey boşluk
          child: Dismissible(
              key: ValueKey('dismissable_${task.id}'),
              direction: (taskViewModel.isSelectionMode || taskViewModel.isSearchMode)
                  ? DismissDirection.none // Arama veya seçim modunda kaydırmayı engelle
                  : (task.status == TaskStatus.BACKLOG)
                  ? DismissDirection.endToStart // Backlog sadece ileri (sola çekince) gidebilir
                  : (task.status == TaskStatus.DONE)
                  ? DismissDirection.startToEnd // Done sadece geri (sağa çekince) gidebilir
                  : DismissDirection.horizontal, // Diğerleri her iki yöne gidebilir

              // --- ARKAPLAN TASARIMLARI ---
              // Sola Kaydırınca (Geri Gitme Rengi - Turuncu/Kırmızı)
              background: Container(
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
                  context.read<TaskViewModel>().updateStatus(context, task, newStatus);
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 5, 16),
                  decoration: BoxDecoration(
                    color: (task.color != null && task.color!.isNotEmpty)
                        ? _parseColor(task.color!, theme)
                        : (isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surface),
                    border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                    // Seçiliyse mavi çerçeve
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [] : [
                      // Seçiliyse gölgeyi kaldır (düz görünsün)
                      BoxShadow(color: theme.shadowColor.withOpacity(0.08),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2)
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                        // Color indicator bar on the left
                        if (task.color != null && task.color!.isNotEmpty)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 6,
                              decoration: BoxDecoration(
                                color: _parseColor(task.color!, theme),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Başlık
                            Padding(
                              padding: const EdgeInsets.only(right: 32.0),
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: (task.color != null && task.color!.isNotEmpty)
                                      ? (_textColorForBackground(task.color!, theme))
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Açıklama
                            Padding(
                              padding: const EdgeInsets.only(right: 32.0),
                              child: Text(
                                task.description,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: (task.color != null && task.color!.isNotEmpty)
                                        ? (_textColorForBackground(task.color!, theme).withOpacity(0.9))
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Alt Satır: Avatar ve Tarih
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    taskAssignees.isEmpty
                                      ? Icon(Icons.person_off_outlined, size: 18, color: theme.colorScheme.surfaceContainerHighest)
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
                                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                            child: Text(
                                              "+${taskAssignees.length - 3}",
                                              style: TextStyle(fontSize: 10,
                                                  color: theme.colorScheme.onSurfaceVariant,
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
                                  const SizedBox(width: 8),
                                  // Tarih Kutucuğu
                                  Flexible(
                                    child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_month_outlined, size: 14,
                                            color: theme.colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 6),
                                        Flexible(child: Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        )
                                      ],
                                    ),
                                  ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      // FAVORI (STAR) + TUTAÇ (DRAG HANDLE)
                      if (!taskViewModel.isSearchMode)
                        Positioned(
                          top: -10,
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Favorite star on card
                              GestureDetector(
                                onTap: () {
                                  if (taskViewModel.isSelectionMode) {
                                    // apply favorite to selected tasks (toggle to true)
                                    taskViewModel.setFavoriteForSelected(context, true);
                                  } else {
                                    taskViewModel.toggleFavorite(context, task);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Icon(
                                    task.favorite ? Icons.star : Icons.star_border,
                                    color: task.favorite ? Colors.amber : Colors.amber.withOpacity(0.6),
                                    size: 24,
                                  ),
                                ),
                              ),

                              ReorderableDragStartListener(
                                index: index,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.transparent,
                                  child: Icon(Icons.drag_indicator, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5), size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )
          ),
        );
      },
    );
  }
}

Color _parseColor(String colorString, ThemeData theme) {
  try {
    var s = colorString.replaceAll('#', '');
    if (s.length == 6) s = 'FF' + s;
    return Color(int.parse(s, radix: 16));
  } catch (_) {
    return theme.colorScheme.surface;
  }
}

Color _textColorForBackground(String colorString, ThemeData theme) {
  final bg = _parseColor(colorString, theme);
  // Compute luminance to decide text color
  return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}


