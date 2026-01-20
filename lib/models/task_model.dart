import 'task_status.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final TaskStatus status;
  final String deadline;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',

      status: stringToTaskStatus(json['status']),

      deadline: json['deadline'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,

      'status': status.toShortString,

      'deadline': deadline,
    };
  }
}