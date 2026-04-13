import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_session_provider.dart';
import '../providers/run_provider.dart';
import '../providers/equipment_provider.dart';
import '../providers/analytics_filter_provider.dart';
import '../widgets/analytics/session_selector.dart';
import '../widgets/analytics/ranked_equipment_list.dart';
import '../widgets/analytics/run_history_list.dart';
import '../widgets/analytics/session_summary_card.dart';
import '../widgets/run_chart_widget.dart';
import '../services/export_service.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final runsAsync = ref.watch(runProvider);
    final equipmentAsync = ref.watch(equipmentProvider);
    final chartFilter = ref.watch(chartFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          if (activeSession != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final allRuns = runsAsync.value ?? [];
                final sessionRuns = allRuns
                    .where((run) => run.sessionId == activeSession.id)
                    .toList();
                final equipmentList = equipmentAsync.value ?? [];

                if (sessionRuns.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No runs in this session to export')),
                  );
                  return;
                }

                ExportService.shareSessionCsv(
                  session: activeSession,
                  runs: sessionRuns,
                  equipment: equipmentList,
                );
              },
              tooltip: 'Export Session CSV',
            ),
        ],
      ),
      body: Column(
        children: [
          const SessionSelector(),
          const Divider(),
          
          if (activeSession != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SegmentedButton<ChartFilter>(
                segments: const [
                  ButtonSegment(
                    value: ChartFilter.allRuns,
                    label: Text('All Runs'),
                    icon: Icon(Icons.show_chart),
                  ),
                  ButtonSegment(
                    value: ChartFilter.compareByEquipment,
                    label: Text('Compare Gear'),
                    icon: Icon(Icons.compare_arrows),
                  ),
                ],
                selected: {chartFilter},
                onSelectionChanged: (newSelection) {
                  ref.read(chartFilterProvider.notifier).state = newSelection.first;
                },
              ),
            ),

          Expanded(
            child: activeSession == null
                ? const Center(child: Text('Select a session to view analytics'))
                : CustomScrollView(
                    slivers: [
                      const SessionSummaryCard(),
                      runsAsync.maybeWhen(
                        data: (allRuns) {
                          final sessionRuns = allRuns
                              .where((run) => run.sessionId == activeSession.id)
                              .toList()
                            ..sort((a, b) => a.id.compareTo(b.id)); // Ascending for trend
                          
                          return equipmentAsync.maybeWhen(
                            data: (equipmentList) => RunChartWidget(
                              runs: sessionRuns,
                              equipment: equipmentList,
                              showByEquipment: chartFilter == ChartFilter.compareByEquipment,
                            ),
                            orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                          );
                        },
                        orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),
                      const RankedEquipmentList(),
                      const RunHistoryList(),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
