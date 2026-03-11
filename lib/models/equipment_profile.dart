class EquipmentProfile {
  final String id;
  final String name;
  final String description;

  EquipmentProfile({
    required this.id,
    required this.name,
    required this.description,
  });

  EquipmentProfile copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return EquipmentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory EquipmentProfile.fromMap(Map<String, dynamic> map) {
    return EquipmentProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
