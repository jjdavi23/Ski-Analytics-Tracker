import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';

final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, TrainingSession?>(() {
  return ActiveSessionNotifier();
});

class ActiveSessionNotifier extends Notifier<TrainingSession?> {
  @override
  TrainingSession? build() {
    return null; // Starts as null until the user picks one
  }

  // The UI must call this method instead of changing the state directly
  void setSession(TrainingSession session) {
    state = session;
  }
}