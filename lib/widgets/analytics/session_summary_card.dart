import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/active_session_provider.dart';
import '../../providers/run_provider.dart';

class SessionSummaryCard extends ConsumerWidget {
  const SessionSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final runsAsync = ref.watch(runProvider);

    if (activeSession == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return runsAsync.when(
      data: (allRuns) {
        final sessionRuns = allRuns
            .where((run) => run.sessionId == activeSession.id)
            .toList();

        if (sessionRuns.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // Calculations
        final double bestRun = sessionRuns
            .map((r) => r.timeInSeconds)
            .reduce((min, val) => val < min ? val : min);

        final double totalTime = sessionRuns.fold(0.0, (sum, r) => sum + r.timeInSeconds);
        final double averageTime = totalTime / sessionRuns.length;

        // Consistency (Standard Deviation)
        final double variance = sessionRuns
                .map((r) => pow(r.timeInSeconds - averageTime, 2))
                .fold(0.0, (sum, val) => sum + val) /
            sessionRuns.length;
        final double stdDev = sqrt(variance);

        return SliverToBoxAdapter(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Best Run', '${bestRun.toStringAsFixed(2)}s', Colors.green),
                      _buildStatItem('Average', '${averageTime.toStringAsFixed(2)}s', Colors.blue),
                      _buildStatItem('Consistency', '±${stdDev.toStringAsFixed(2)}s', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
