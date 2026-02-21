class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.ownerName,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? description;
  final int ownerId;
  final String? ownerName;
  final DateTime? createdAt;

  factory Workspace.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'];

    return Workspace(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      ownerId: _parseInt(json['ownerId'] ?? json['owner_id']),
      ownerName: _parseOwnerName(owner, fallback: json['ownerName'] ?? json['owner_name']),
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

  static String? _parseOwnerName(dynamic owner, {dynamic fallback}) {
    if (owner is Map<String, dynamic>) {
      final firstName = (owner['firstName'] ?? '').toString().trim();
      final lastName = (owner['lastName'] ?? '').toString().trim();
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }

      final ownerDisplayName = (owner['name'] ?? '').toString().trim();
      if (ownerDisplayName.isNotEmpty) {
        return ownerDisplayName;
      }
    }

    final fallbackName = (fallback ?? '').toString().trim();
    if (fallbackName.isNotEmpty) {
      return fallbackName;
    }

    return null;
  }
}
