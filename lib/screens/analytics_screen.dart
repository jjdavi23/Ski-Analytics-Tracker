import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../models/training_run.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/run_provider.dart';
import '../providers/equipment_provider.dart';
import '../widgets/sync_error_widget.dart';
import '../models/equipment_profile.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final analytics = ref.watch(analyticsProvider);
    final runsAsync = ref.watch(runProvider);
    final equipmentAsync = ref.watch(equipmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: Column(
        children: [
          if (sessionsAsync.isLoading && !sessionsAsync.hasValue)
            const LinearProgressIndicator(),
            
          sessionsAsync.when(
            skipLoadingOnRefresh: true,
            data: (sessions) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: sessions.any((s) => s.id == activeSession?.id) ? activeSession?.id : null,
                decoration: const InputDecoration(
                  labelText: 'Select Training Session',
                  border: OutlineInputBorder(),
                ),
                items: sessions.map((session) {
                  return DropdownMenuItem(
                    value: session.id,
                    child: Text('${session.location} (${session.date.month}/${session.date.day})'),
                  );
                }).toList(),
                onChanged: (sessionId) {
                  if (sessionId != null) {
                    ref.read(sessionIdProvider.notifier).setSessionId(sessionId);
                  }
                },
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => SyncErrorWidget(
              message: 'Failed to load sessions',
              onRetry: () => ref.invalidate(sessionProvider),
            ),
          ),
          const Divider(),
          
          Expanded(
            child: activeSession == null
                ? const Center(child: Text('Select a session to view analytics'))
                : CustomScrollView(
                    slivers: [
                      if (analytics.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Ranked Setups (Fastest First)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = analytics[index];
                              final isFastest = index == 0;
                              return _AnalyticsCard(item: item, index: index, isFastest: isFastest);
                            },
                            childCount: analytics.length,
                          ),
                        ),
                      ],
                      
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Session History',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      runsAsync.when(
                        data: (allRuns) {
                          final sessionRuns = allRuns
                              .where((run) => run.sessionId == activeSession.id)
                              .toList()
                            ..sort((a, b) => b.id.compareTo(a.id)); 

                          if (sessionRuns.isEmpty) {
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
                                    final run = sessionRuns[index];
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
                                  childCount: sessionRuns.length,
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
                      
                      const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                    ],
                  ),
          ),
        ],
      ),
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
          decoration: const InputDecoration(labelText: 'Time (seconds)', suffixText: 's'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTime = double.tryParse(controller.text);
              if (newTime != null && newTime > 0) {
                ref.read(runProvider.notifier).updateRun(run.copyWith(timeInSeconds: newTime));
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

class _AnalyticsCard extends StatelessWidget {
  final EquipmentAnalytics item;
  final int index;
  final bool isFastest;

  const _AnalyticsCard({
    required this.item,
    required this.index,
    required this.isFastest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isFastest ? Colors.green.withValues(alpha: 0.1) : null,
      elevation: isFastest ? 4 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isFastest ? Colors.green : Colors.blueGrey,
          child: Text('#${index + 1}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          item.equipment.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${item.runCount} total runs'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.averageTime.toStringAsFixed(2)}s',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isFastest ? Colors.green : Colors.blue,
              ),
            ),
            const Text('avg time', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}