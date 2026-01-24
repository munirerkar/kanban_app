import 'task_status.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final TaskStatus status;
  final String deadline;
  final List<int> assigneeIds;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    this.assigneeIds = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    var assigneeData = json['assignees'];
    List<int> safeIds = [];

    if (assigneeData is List) {
      // Eğer gelen veri gerçekten bir listeyse işle
      safeIds = assigneeData.map((item) {
        if (item is Map) {
          return item['id'] as int?;
        } else if (item is int) {
          return item;
        }
        return null;
      }).whereType<int>().toList();
    }
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: stringToTaskStatus(json['status']),
      deadline: json['deadline'] ?? '',
      assigneeIds: safeIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.toShortString,
      'deadline': deadline,
      'assigneeIds': assigneeIds,
    };
  }
  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    String? deadline,
    List<int>? assigneeIds,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      assigneeIds: assigneeIds ?? this.assigneeIds,
    );
  }
}