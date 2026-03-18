import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_run.dart';

//tells other screens about list of runs
final runProvider = NotifierProvider<RunNotifier, List<TrainingRun>>(() {
  return RunNotifier();
});

//contains the actual data, and determines how it can be edited
class RunNotifier extends Notifier<List<TrainingRun>> {
  
  //riverpod calls this when method when the app is opened
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


 //adds new run to the end of the run list
 // spread operator (...) breaks down the list in order to add new run to end
  void addRun(TrainingRun run) {
    state = [...state, run];
  }
}