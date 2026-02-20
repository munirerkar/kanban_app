class User {
  final int id;
  final String name;
  final String? email;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    this.email,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();

    return User(
      id: _parseInt(json['id']),
      name: _resolveName(json: json, fallbackFullName: fullName),
      email: json['email']?.toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
    );
  }

  static String _resolveName({
    required Map<String, dynamic> json,
    required String fallbackFullName,
  }) {
    final backendName = (json['name'] ?? '').toString().trim();
    if (backendName.isNotEmpty) {
      return backendName;
    }

    if (fallbackFullName.isNotEmpty) {
      return fallbackFullName;
    }

    return '';
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
}