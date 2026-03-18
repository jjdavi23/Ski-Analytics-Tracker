import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';


//tells the other screens what session is active
final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, TrainingSession?>(() {
  return ActiveSessionNotifier();
});


//holds data and determines how it can be changed
//extends Notifier which tells Riverpod to watch it so that
//it can rebuild UI when something changes
class ActiveSessionNotifier extends Notifier<TrainingSession?> {
  
  //starts as null until the user picks a training session
  @override
  TrainingSession? build() {
    return null; 
  }

  //the UI has to call this method instead of changing the state directly
  void setSession(TrainingSession session) {
    state = session;
  }
}