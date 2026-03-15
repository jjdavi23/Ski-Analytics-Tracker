import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_run.dart';


final runProvider = NotifierProvider<RunNotifier, List<TrainingRun>>(() {
  return RunNotifier();
});

class RunNotifier extends Notifier<List<TrainingRun>> {
  
  
  @override
  List<TrainingRun> build() {
    return [
      TrainingRun(
        id: 'r1',
        timeInSeconds: 45.45,
        sessionId: 's1',
        equipmentProfileId: '1', // Matches mock id in equipment_provider
      ),
      TrainingRun(
        id: 'r2',
        timeInSeconds: 46.12,
        sessionId: 's1',
        equipmentProfileId: '2',
      ),
    ];
  }

  void addRun(TrainingRun run) {
    state = [...state, run];
  }
}