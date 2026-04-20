class Folder {
  final String id;
  final String name;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Folder copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
