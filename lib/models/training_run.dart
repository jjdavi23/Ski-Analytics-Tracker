class TrainingRun {
  final String id;
  final double timeInSeconds;
  final String sessionId;
  final String equipmentProfileId;
  final DateTime timestamp;

  TrainingRun({
    required this.id,
    required this.timeInSeconds,
    required this.sessionId,
    required this.equipmentProfileId,
    required this.timestamp,
  });

  TrainingRun copyWith({
    String? id,
    double? timeInSeconds,
    String? sessionId,
    String? equipmentProfileId,
    DateTime? timestamp,
  }) {
    return TrainingRun(
      id: id ?? this.id,
      timeInSeconds: timeInSeconds ?? this.timeInSeconds,
      sessionId: sessionId ?? this.sessionId,
      equipmentProfileId: equipmentProfileId ?? this.equipmentProfileId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timeInSeconds': timeInSeconds,
      'sessionId': sessionId,
      'equipmentProfileId': equipmentProfileId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TrainingRun.fromMap(Map<String, dynamic> map) {
    return TrainingRun(
      id: map['id'] ?? '',
      timeInSeconds: (map['timeInSeconds'] ?? 0.0).toDouble(),
      sessionId: map['sessionId'] ?? '',
      equipmentProfileId: map['equipmentProfileId'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }
}
