import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import 'session_provider.dart';

final activeSessionProvider = StateProvider<TrainingSession?>((ref) {
  final sessions = ref.watch(sessionProvider);
  return sessions.isNotEmpty ? sessions.first : null;
});
