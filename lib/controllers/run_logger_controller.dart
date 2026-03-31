import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment_profile.dart';
import '../models/training_run.dart';
import '../providers/active_session_provider.dart';
import '../providers/run_provider.dart';

// 1. THE STATE
class RunLoggerState {
  final String timeInput;
  final EquipmentProfile? selectedEquipment;

  RunLoggerState({
    this.timeInput = '',
    this.selectedEquipment,
  });

  RunLoggerState copyWith({
    String? timeInput,
    EquipmentProfile? selectedEquipment,
  }) {
    return RunLoggerState(
      timeInput: timeInput ?? this.timeInput,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
    );
  }
}

// 2. THE PROVIDER (Modern 3.0 AutoDispose Syntax)
final runLoggerControllerProvider = 
    NotifierProvider<RunLoggerController, RunLoggerState>(() {
  return RunLoggerController();
});

// 3. THE CONTROLLER
class RunLoggerController extends Notifier<RunLoggerState> {
  
  @override
  RunLoggerState build() {
    return RunLoggerState(); // Starts empty
  }

  void handleKeyPress(String key) {
    String currentInput = state.timeInput;
    if (key == '.' && currentInput.contains('.')) return;
    if (currentInput.contains('.') && currentInput.split('.')[1].length >= 2) return;
    state = state.copyWith(timeInput: currentInput + key);
  }

  void handleDelete() {
    if (state.timeInput.isNotEmpty) {
      state = state.copyWith(
        timeInput: state.timeInput.substring(0, state.timeInput.length - 1),
      );
    }
  }

  void handleClear() {
    state = state.copyWith(timeInput: '');
  }

  void setSelectedEquipment(EquipmentProfile? profile) {
    state = state.copyWith(selectedEquipment: profile);
  }

  // Returns a specific error message if it fails, or null if it succeeds
  String? saveRun() {
    // In Riverpod 3.0 Notifiers, 'ref' is built-in automatically!
    final activeSession = ref.read(activeSessionProvider);
    
    if (activeSession == null) return 'Please select or create a session first.';
    if (state.selectedEquipment == null) return 'Please select your equipment.';

    final time = double.tryParse(state.timeInput);
    if (time == null || time <= 0) return 'Please enter a valid time.';

    final newRun = TrainingRun(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timeInSeconds: time,
      sessionId: activeSession.id,
      equipmentProfileId: state.selectedEquipment!.id,
    );

    ref.read(runProvider.notifier).addRun(newRun);
    handleClear(); //clear the numpad on success
    return null; //null means no errors!
  }
}