import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/training_run.dart';
import '../../models/equipment_profile.dart';
import '../../providers/run_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/active_session_provider.dart';

class RunHistoryList extends ConsumerWidget {
  const RunHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(sessionIdProvider);
    final runsAsync = ref.watch(runProvider);
    final equipmentAsync = ref.watch(equipmentProvider);

    if (sessionId == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              sessionId == 'all_time' ? 'All Time History' : 'Session History',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        runsAsync.when(
          data: (allRuns) {
            final filteredRuns = sessionId == 'all_time'
                ? allRuns
                : allRuns.where((run) => run.sessionId == sessionId).toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (filteredRuns.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No individual runs found.'),
                  ),
                ),
              );
            }

            return equipmentAsync.maybeWhen(
              data: (equipmentList) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final run = filteredRuns[index];
                      final equipment = equipmentList.firstWhere(
                        (e) => e.id == run.equipmentProfileId,
                        orElse: () => EquipmentProfile(
                            id: 'unknown', name: 'Unknown', description: ''),
                      );

                      return ListTile(
                        title: Text('${run.timeInSeconds.toStringAsFixed(2)}s'),
                        subtitle: Text('Gear: ${equipment.name}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditTimeDialog(context, ref, run),
                              tooltip: 'Edit Time',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                ref.read(runProvider.notifier).deleteRun(run.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Run deleted')),
                                );
                              },
                              tooltip: 'Delete Run',
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: filteredRuns.length,
                  ),
                );
              },
              orElse: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SliverToBoxAdapter(
            child: Center(child: Text('Error loading history: $err')),
          ),
        ),
      ],
    );
  }

  void _showEditTimeDialog(BuildContext context, WidgetRef ref, TrainingRun run) {
    final controller = TextEditingController(text: run.timeInSeconds.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Run Time'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(labelText: 'Time (seconds)', suffixText: 's'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTime = double.tryParse(controller.text);
              if (newTime != null && newTime > 0) {
                ref
                    .read(runProvider.notifier)
                    .updateRun(run.copyWith(timeInSeconds: newTime));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Time updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}