import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';


//sends list of training days to screens
final sessionProvider = NotifierProvider<SessionNotifier, List<TrainingSession>>(() {
  return SessionNotifier();
});

//contains actual list of sessions, and determines how they can be edited
class SessionNotifier extends Notifier<List<TrainingSession>> {
  
  //called when app boots up
  //hardcoded with dummy data for now
  @override
  List<TrainingSession> build() {
    return[
    TrainingSession(
      id: 's1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Whiteface Mt.',
      snowCondition: 'Hard Packed',
    ),
    TrainingSession(
      id: 's2',
      date: DateTime.now(),
      location: 'Gore Mountain',
      snowCondition: 'Icy',
    ),
  ];
}

//creates new session and adds it to the list at the end
  void addSession(TrainingSession session) {
    state = [...state, session];
  }
}
