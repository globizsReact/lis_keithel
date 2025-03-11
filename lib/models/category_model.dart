// lib/models/category.dart
class Category {
  final String id;
  final String name;
  final String description;
  final String status;
  final String photo;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.photo,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      photo: json['photo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'photo': photo,
    };
  }
}
