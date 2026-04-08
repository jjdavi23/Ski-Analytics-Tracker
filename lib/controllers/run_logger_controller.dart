import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_run.dart';
import '../providers/active_session_provider.dart';
import '../providers/run_provider.dart';

// 1. THE STATE
class RunLoggerState {
  final String timeInput;
  final String? selectedEquipmentId; // Store only the ID
  final bool isLoading; 

  RunLoggerState({
    this.timeInput = '',
    this.selectedEquipmentId,
    this.isLoading = false,
  });

  RunLoggerState copyWith({
    String? timeInput,
    String? selectedEquipmentId,
    bool? isLoading,
  }) {
    return RunLoggerState(
      timeInput: timeInput ?? this.timeInput,
      selectedEquipmentId: selectedEquipmentId ?? this.selectedEquipmentId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. THE PROVIDER
final runLoggerControllerProvider = 
    NotifierProvider<RunLoggerController, RunLoggerState>(() {
  return RunLoggerController();
});

// 3. THE CONTROLLER
class RunLoggerController extends Notifier<RunLoggerState> {
  
  @override
  RunLoggerState build() {
    return RunLoggerState(); 
  }

  void handleKeyPress(String key) {
    if (state.isLoading) return;
    String currentInput = state.timeInput;
    if (key == '.' && currentInput.contains('.')) return;
    if (currentInput.contains('.') && currentInput.split('.')[1].length >= 2) return;
    state = state.copyWith(timeInput: currentInput + key);
  }

  void handleDelete() {
    if (state.isLoading) return;
    if (state.timeInput.isNotEmpty) {
      state = state.copyWith(
        timeInput: state.timeInput.substring(0, state.timeInput.length - 1),
      );
    }
  }

  void handleClear() {
    state = state.copyWith(timeInput: '');
  }

  void setSelectedEquipmentId(String? id) {
    state = state.copyWith(selectedEquipmentId: id);
  }

  Future<String?> saveRun() async {
    final activeSession = ref.read(activeSessionProvider);
    if (activeSession == null) return 'Select a session first.';
    if (state.selectedEquipmentId == null) return 'Select equipment.';

    final time = double.tryParse(state.timeInput);
    if (time == null || time <= 0) return 'Enter a valid time.';

    // 1. Enter Loading State
    state = state.copyWith(isLoading: true);

    try {
      final newRun = TrainingRun(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timeInSeconds: time,
        sessionId: activeSession.id,
        equipmentProfileId: state.selectedEquipmentId!,
      );

      // 2. Perform the add. 
      await ref.read(runProvider.notifier).addRun(newRun);
      
      // 3. Reset input on success
      handleClear();
      return null; 
    } catch (e) {
      return e.toString();
    } finally {
      // 4. Force state update back to false
      state = state.copyWith(isLoading: false);
    }
  }
}
