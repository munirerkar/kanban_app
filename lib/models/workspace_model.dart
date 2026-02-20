class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? description;
  final int ownerId;
  final DateTime? createdAt;

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      ownerId: _parseInt(json['ownerId'] ?? json['owner_id']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
