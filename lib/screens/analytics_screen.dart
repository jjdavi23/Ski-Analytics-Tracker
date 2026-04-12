import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_session_provider.dart';
import '../providers/run_provider.dart';
import '../widgets/analytics/session_selector.dart';
import '../widgets/analytics/ranked_equipment_list.dart';
import '../widgets/analytics/run_history_list.dart';
import '../widgets/run_chart_widget.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final runsAsync = ref.watch(runProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: Column(
        children: [
          const SessionSelector(),
          const Divider(),
          
          Expanded(
            child: activeSession == null
                ? const Center(child: Text('Select a session to view analytics'))
                : CustomScrollView(
                    slivers: [
                      runsAsync.maybeWhen(
                        data: (allRuns) {
                          final sessionRuns = allRuns
                              .where((run) => run.sessionId == activeSession.id)
                              .toList()
                            ..sort((a, b) => a.id.compareTo(b.id)); // Ascending for trend
                          return RunChartWidget(runs: sessionRuns);
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
