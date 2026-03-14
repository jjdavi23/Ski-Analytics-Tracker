import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';

final sessionProvider = StateNotifierProvider<SessionNotifier, List<TrainingSession>>((ref) {
  return SessionNotifier();
});

class SessionNotifier extends StateNotifier<List<TrainingSession>> {
  SessionNotifier() : super([
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
  ]);

  void addSession(TrainingSession session) {
    state = [...state, session];
  }
}
