import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_run.dart';
import 'equipment_provider.dart';

final runProvider = StreamNotifierProvider<RunNotifier, List<TrainingRun>>(() {
  return RunNotifier();
});

class RunNotifier extends StreamNotifier<List<TrainingRun>> {
  @override
  Stream<List<TrainingRun>> build() {
    final dbService = ref.watch(databaseServiceProvider);
    if (dbService == null) {
      return Stream.value([]);
    }
    return dbService.trainingRuns;
  }

  Future<void> addRun(TrainingRun run) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService != null) {
      await dbService.createTrainingRun(run);
    }
  }

  Future<void> deleteRun(String id) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService != null) {
      await dbService.deleteTrainingRun(id);
    }
  }
}
