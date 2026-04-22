import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_session_provider.dart';
import '../providers/run_provider.dart';
import '../providers/equipment_provider.dart';
import '../providers/analytics_filter_provider.dart';
// FIX 1: Add the missing model import
import '../widgets/analytics/session_selector.dart';
import '../widgets/analytics/ranked_equipment_list.dart';
import '../widgets/analytics/run_history_list.dart';
import '../widgets/analytics/session_summary_card.dart';
import '../widgets/analytics/equipment_comparison_card.dart';
import '../widgets/run_chart_widget.dart';
import '../services/export_service.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final sessionId = ref.watch(sessionIdProvider);
    final runsAsync = ref.watch(runProvider);
    final equipmentAsync = ref.watch(equipmentProvider);
    final chartFilter = ref.watch(chartFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          if (sessionId != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final allRuns = runsAsync.value ?? [];
                final sessionRuns = sessionId == 'all_time'
                    ? allRuns
                    : allRuns.where((run) => run.sessionId == sessionId).toList();
                final equipmentList = equipmentAsync.value ?? [];

                if (sessionRuns.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No runs to export')),
                  );
                  return;
                }

                // FIX 2: Use the updated shareCsv method and simplify logic
                ExportService.shareCsv(
                  session: sessionId == 'all_time' ? null : activeSession,
                  runs: sessionRuns,
                  equipment: equipmentList,
                );
              },
              tooltip: 'Export CSV',
            ),
        ],
      ),
      body: Column(
        children: [
          const SessionSelector(),
          const Divider(),
          
          if (sessionId != null)
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
                  ref.read(chartFilterProvider.notifier).setFilter(newSelection.first);
                },
              ),
            ),

          Expanded(
            child: sessionId == null
                ? const Center(child: Text('Select a session to view analytics'))
                : CustomScrollView(
                    slivers: [
                      const SessionSummaryCard(),
                      runsAsync.maybeWhen(
                        data: (allRuns) {
                          final sessionRuns = sessionId == 'all_time'
                              ? allRuns
                              : allRuns.where((run) => run.sessionId == sessionId).toList();
                          
                          // Sort for the trend chart: Ascending (oldest to newest)
                          sessionRuns.sort((a, b) => a.id.compareTo(b.id)); 
                          
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
                      const EquipmentComparisonCard(),
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