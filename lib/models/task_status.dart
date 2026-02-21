// ignore_for_file: constant_identifier_names

enum TaskStatus {
  BACKLOG,
  TODO,
  IN_PROGRESS,
  DONE,
}

// Backend'den gelen status yazısını Enum'a çeviren yardımcı metot
TaskStatus stringToTaskStatus(String status) {
  final normalized = status.trim().toUpperCase();

  switch (normalized) {
    case 'BACKLOG':
      return TaskStatus.BACKLOG;
    case 'IN_PROGRESS':
      return TaskStatus.IN_PROGRESS;
    case 'DONE':
      return TaskStatus.DONE;
    case 'TODO':
    default:
      return TaskStatus.TODO;
  }
}

// Enum'ı Backend'e gönderirken String'e çeviren yardımcı metot (Extension)
extension TaskStatusExtension on TaskStatus {
  String get toShortString => name;
}