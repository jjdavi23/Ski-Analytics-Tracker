class TrainingRun {
  final String id;
  final double timeInSeconds;
  final String sessionId;
  final String equipmentProfileId;

  TrainingRun({
    required this.id,
    required this.timeInSeconds,
    required this.sessionId,
    required this.equipmentProfileId,
  });

  TrainingRun copyWith({
    String? id,
    double? timeInSeconds,
    String? sessionId,
    String? equipmentProfileId,
  }) {
    return TrainingRun(
      id: id ?? this.id,
      timeInSeconds: timeInSeconds ?? this.timeInSeconds,
      sessionId: sessionId ?? this.sessionId,
      equipmentProfileId: equipmentProfileId ?? this.equipmentProfileId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timeInSeconds': timeInSeconds,
      'sessionId': sessionId,
      'equipmentProfileId': equipmentProfileId,
    };
  }

  factory TrainingRun.fromMap(Map<String, dynamic> map) {
    return TrainingRun(
      id: map['id'] ?? '',
      timeInSeconds: (map['timeInSeconds'] ?? 0.0).toDouble(),
      sessionId: map['sessionId'] ?? '',
      equipmentProfileId: map['equipmentProfileId'] ?? '',
    );
  }
}
