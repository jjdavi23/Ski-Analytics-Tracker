import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import 'session_provider.dart';
import 'shared_preferences_provider.dart';

const String _activeSessionIdKey = 'active_session_id';

// 1. The ID Provider (Stores only the String ID)
final sessionIdProvider = NotifierProvider<ActiveSessionIdNotifier, String?>(() {
  return ActiveSessionIdNotifier();
});

class ActiveSessionIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_activeSessionIdKey);
  }

  void setSessionId(String? id) {
    state = id;
    final prefs = ref.read(sharedPreferencesProvider);
    if (id == null) {
      prefs.remove(_activeSessionIdKey);
    } else {
      prefs.setString(_activeSessionIdKey, id);
    }
  }
}

// 2. The Derived Provider (Returns the actual TrainingSession object)
final activeSessionProvider = Provider<TrainingSession?>((ref) {
  final sessionId = ref.watch(sessionIdProvider);
  final sessionsAsync = ref.watch(sessionProvider);

  return sessionsAsync.when(
    data: (sessions) {
      if (sessionId == null) return null;
      try {
        return sessions.firstWhere((s) => s.id == sessionId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
