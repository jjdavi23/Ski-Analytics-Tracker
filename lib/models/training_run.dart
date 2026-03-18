//class links time to training session to equipment profile 
class TrainingRun {
//stores id strings
  final String id;
  final double timeInSeconds;
  final String sessionId;
  final String equipmentProfileId;



  TrainingRun({

    //all of these required for a run to be stored in the database
    required this.id,
    required this.timeInSeconds,
    required this.sessionId,
    required this.equipmentProfileId,
  });

  TrainingRun copyWith({
    //create a new TrainingRun object if you need to edit a run
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

//conversion for firestore
  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'timeInSeconds': timeInSeconds,
      'sessionId': sessionId,
      'equipmentProfileId': equipmentProfileId,
    };
  }

//conversion from firestore
  factory TrainingRun.fromMap(Map<String, dynamic> map) {
    return TrainingRun(
      id: map['id'] ?? '',
      timeInSeconds: (map['timeInSeconds'] ?? 0.0).toDouble(),
      sessionId: map['sessionId'] ?? '',
      equipmentProfileId: map['equipmentProfileId'] ?? '',
    );
  }
}
