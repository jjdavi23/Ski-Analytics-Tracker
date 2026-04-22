import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment_profile.dart';
import '../models/training_run.dart';
import 'active_session_provider.dart';
import 'run_provider.dart';
import 'equipment_provider.dart';

// 1. This class MUST be outside the provider and not start with an underscore
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
  final sessionId = ref.watch(sessionIdProvider);
  
  // Use .value ?? [] to safely unwrap the AsyncValues from Firebase
  final allRuns = ref.watch(runProvider).value ?? [];
  final allEquipment = ref.watch(equipmentProvider).value ?? [];

  if (sessionId == null) return [];

  // Filter runs: either for a specific session or all runs if 'all_time'
  final List<TrainingRun> filteredRuns = sessionId == 'all_time' 
      ? allRuns 
      : allRuns.where((run) => run.sessionId == sessionId).toList();

  if (filteredRuns.isEmpty) return [];

  final Map<String, List<TrainingRun>> groupedRuns = {};
  for (var run in filteredRuns) {
    groupedRuns.putIfAbsent(run.equipmentProfileId, () => []).add(run);
  }

  final List<EquipmentAnalytics> analyticsList = [];
  for (var entry in groupedRuns.entries) {
    final equipment = allEquipment.firstWhere(
      (e) => e.id == entry.key,
      orElse: () => EquipmentProfile(id: 'unknown', name: 'Unknown Gear', description: ''),
    );

    final totalTime = entry.value.fold(0.0, (sum, run) => sum + run.timeInSeconds);
    
    analyticsList.add(EquipmentAnalytics(
      equipment: equipment,
      averageTime: totalTime / entry.value.length,
      runCount: entry.value.length,
    ));
  }

  analyticsList.sort((a, b) => a.averageTime.compareTo(b.averageTime));
  return analyticsList;
});