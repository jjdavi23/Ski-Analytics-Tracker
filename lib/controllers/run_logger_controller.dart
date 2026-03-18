import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment_profile.dart';
import '../models/training_run.dart';
import '../providers/active_session_provider.dart';
import '../providers/run_provider.dart';

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

final runLoggerControllerProvider =
    StateNotifierProvider<RunLoggerController, RunLoggerState>((ref) {
  return RunLoggerController(ref);
});

class RunLoggerController extends StateNotifier<RunLoggerState> {
  final Ref _ref;

  RunLoggerController(this._ref) : super(RunLoggerState());

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

  bool saveRun() {
    final activeSession = _ref.read(activeSessionProvider);
    if (activeSession == null) return false;
    if (state.selectedEquipment == null) return false;

    final time = double.tryParse(state.timeInput);
    if (time == null || time <= 0) return false;

    final newRun = TrainingRun(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timeInSeconds: time,
      sessionId: activeSession.id,
      equipmentProfileId: state.selectedEquipment!.id,
    );

    _ref.read(runProvider.notifier).addRun(newRun);
    handleClear();
    return true;
  }
}
