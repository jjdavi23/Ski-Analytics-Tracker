import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import 'equipment_provider.dart';

final sessionProvider = StreamNotifierProvider<SessionNotifier, List<TrainingSession>>(() {
  return SessionNotifier();
});

class SessionNotifier extends StreamNotifier<List<TrainingSession>> {
  @override
  Stream<List<TrainingSession>> build() {
    final dbService = ref.watch(databaseServiceProvider);
    if (dbService == null) {
      return Stream.value([]);
    }
    return dbService.trainingSessions;
  }

  Future<void> addSession(TrainingSession session) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService != null) {
      await dbService.createTrainingSession(session);
    }
  }

  Future<void> deleteSession(String id) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService != null) {
      await dbService.deleteTrainingSession(id);
    }
  }

  Future<void> moveSession(String sessionId, String newFolderId) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService == null) return;

    // We need to get the current session data to update its folderId
    final sessions = await future;
    final session = sessions.firstWhere((s) => s.id == sessionId);
    
    final updatedSession = session.copyWith(folderId: newFolderId);
    await dbService.updateTrainingSession(updatedSession);
  }
}

final sessionsInFolderProvider = Provider.family<AsyncValue<List<TrainingSession>>, String>((ref, folderId) {
  final sessionsAsync = ref.watch(sessionProvider);
  return sessionsAsync.whenData((sessions) => 
    sessions.where((session) => session.folderId == folderId).toList()
  );
});
