import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment_profile.dart';
import '../models/training_run.dart';
import 'active_session_provider.dart';
import 'run_provider.dart';
import 'equipment_provider.dart';

class EquipmentAnalytics {
  final EquipmentProfile equipment;
  final double averageTime;
  final int runCount;

  EquipmentAnalytics({
    required this.equipment,
    required this.averageTime,
    required this.runCount,
  });
}

final analyticsProvider = Provider<List<EquipmentAnalytics>>((ref) {
  final activeSession = ref.watch(activeSessionProvider);
  final allRuns = ref.watch(runProvider);
  final allEquipment = ref.watch(equipmentProvider);

  if (activeSession == null) {
    return [];
  }

  // Filter runs for the active session
  final sessionRuns = allRuns.where((run) => run.sessionId == activeSession.id).toList();

  if (sessionRuns.isEmpty) {
    return [];
  }

  // Group runs by equipment ID
  final Map<String, List<TrainingRun>> groupedRuns = {};
  for (var run in sessionRuns) {
    if (!groupedRuns.containsKey(run.equipmentProfileId)) {
      groupedRuns[run.equipmentProfileId] = [];
    }
    groupedRuns[run.equipmentProfileId]!.add(run);
  }

  // Calculate averages
  final List<EquipmentAnalytics> analyticsList = [];
  for (var entry in groupedRuns.entries) {
    final equipmentId = entry.key;
    final runs = entry.value;

    final equipment = allEquipment.firstWhere(
      (e) => e.id == equipmentId,
      orElse: () => EquipmentProfile(id: 'unknown', name: 'Unknown Gear', description: ''),
    );

    final totalTime = runs.fold(0.0, (sum, run) => sum + run.timeInSeconds);
    final averageTime = totalTime / runs.length;

    analyticsList.add(EquipmentAnalytics(
      equipment: equipment,
      averageTime: averageTime,
      runCount: runs.length,
    ));
  }

  // Sort by average time (fastest first)
  analyticsList.sort((a, b) => a.averageTime.compareTo(b.averageTime));

  return analyticsList;
});
