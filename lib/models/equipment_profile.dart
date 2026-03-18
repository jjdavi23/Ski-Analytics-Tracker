class EquipmentProfile {
  //outline for ski setup
  final String id;
  final String name;
  final String description;

  EquipmentProfile({
    //whats needed to make the equipment profile
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

 //allows firestore to store the profile in the cloud
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  //converts the toMap version of the profile back into EquipmentProfile object
  factory EquipmentProfile.fromMap(Map<String, dynamic> map) {
    return EquipmentProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
