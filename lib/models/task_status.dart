enum TaskStatus {
  BACKLOG,
  TODO,
  IN_PROGRESS,
  DONE
}

// Backend'den gelen "TODO" yazısını Enum'a çeviren yardımcı metot
TaskStatus stringToTaskStatus(String status) {
  try {
    return TaskStatus.values.firstWhere(
            (e) => e.name == status,
        orElse: () => TaskStatus.TODO
    );
  } catch (e) {
    return TaskStatus.TODO;
  }
}

// Enum'ı Backend'e gönderirken String'e çeviren yardımcı metot (Extension)
extension TaskStatusExtension on TaskStatus {
  String get toShortString => this.name; //
}