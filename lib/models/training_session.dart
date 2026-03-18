//block of training
class TrainingSession {
  final String id;
  final DateTime date;
  final String location;
  final String snowCondition;

//things needed for TrainingSession object
  TrainingSession({
    required this.id,
    required this.date,
    required this.location,
    required this.snowCondition,
  });
//Creates new copy if edits are made
  TrainingSession copyWith({
    String? id,
    DateTime? date,
    String? location,
    String? snowCondition,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      date: date ?? this.date,
      location: location ?? this.location,
      snowCondition: snowCondition ?? this.snowCondition,
    );
  }

  //converts data into text string for firestore

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'location': location,
      'snowCondition': snowCondition,
    };
  }

//converts back into object
  factory TrainingSession.fromMap(Map<String, dynamic> map) {
    return TrainingSession(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      location: map['location'] ?? '',
      snowCondition: map['snowCondition'] ?? '',
    );
  }
}
