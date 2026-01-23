class User {
  final int id;
  final String name;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'İsimsiz',
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}