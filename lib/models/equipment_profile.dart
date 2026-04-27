class EquipmentProfile {
  //outline for ski setup
  final String id;
  final String name;
  final String? stackHeight;
  final String? baseBevel;
  final String? sideEdge;
  final String? skiModel;
  final String? notes;

  EquipmentProfile({
    //whats needed to make the equipment profile
    required this.id,
    required this.name,
    this.stackHeight,
    this.baseBevel,
    this.sideEdge,
    this.skiModel,
    this.notes,
  });

  EquipmentProfile copyWith({
    String? id,
    String? name,
    String? stackHeight,
    String? baseBevel,
    String? sideEdge,
    String? skiModel,
    String? notes,
  }) {
    return EquipmentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      stackHeight: stackHeight ?? this.stackHeight,
      baseBevel: baseBevel ?? this.baseBevel,
      sideEdge: sideEdge ?? this.sideEdge,
      skiModel: skiModel ?? this.skiModel,
      notes: notes ?? this.notes,
    );
  }

 //allows firestore to store the profile in the cloud
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stackHeight': stackHeight,
      'baseBevel': baseBevel,
      'sideEdge': sideEdge,
      'skiModel': skiModel,
      'notes': notes,
    };
  }

  //converts the toMap version of the profile back into EquipmentProfile object
  factory EquipmentProfile.fromMap(Map<String, dynamic> map) {
    return EquipmentProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      stackHeight: map['stackHeight'],
      baseBevel: map['baseBevel'],
      sideEdge: map['sideEdge'],
      skiModel: map['skiModel'],
      notes: map['notes'],
    );
  }

  // Helper to get a summary string for display in places that used description
  String get description {
    final List<String> parts = [];
    if (skiModel != null && skiModel!.isNotEmpty) parts.add('Model: $skiModel');
    if (stackHeight != null && stackHeight!.isNotEmpty) parts.add('Stack: $stackHeight');
    if (baseBevel != null && baseBevel!.isNotEmpty) parts.add('Base: $baseBevel');
    if (sideEdge != null && sideEdge!.isNotEmpty) parts.add('Side: $sideEdge');
    return parts.isEmpty ? 'No details' : parts.join(', ');
  }
}
