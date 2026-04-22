//block of training
class TrainingSession {
  final String id;
  final String folderId;
  final DateTime date;
  final String location;
  final String snowCondition;
  final double? temperature; // Added temperature
  final String? wax; // Added wax

//things needed for TrainingSession object
  TrainingSession({
    required this.id,
    required this.folderId,
    required this.date,
    required this.location,
    required this.snowCondition,
    this.temperature,
    this.wax,
  });

//Creates new copy if edits are made
  TrainingSession copyWith({
    String? id,
    String? folderId,
    DateTime? date,
    String? location,
    String? snowCondition,
    double? temperature,
    String? wax,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      date: date ?? this.date,
      location: location ?? this.location,
      snowCondition: snowCondition ?? this.snowCondition,
      temperature: temperature ?? this.temperature,
      wax: wax ?? this.wax,
    );
  }

  //converts data into text string for firestore

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folderId': folderId,
      'date': date.toIso8601String(),
      'location': location,
      'snowCondition': snowCondition,
      'temperature': temperature,
      'wax': wax,
    };
  }

//converts back into object
  factory TrainingSession.fromMap(Map<String, dynamic> map) {
    return TrainingSession(
      id: map['id'] ?? '',
      folderId: map['folderId'] ?? 'uncategorized',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      location: map['location'] ?? '',
      snowCondition: map['snowCondition'] ?? '',
      temperature: (map['temperature'] as num?)?.toDouble(),
      wax: map['wax'],
    );
  }
}
