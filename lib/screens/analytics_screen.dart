import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/sync_error_widget.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: Column(
        children: [
          // Non-blocking loading indicator at the top
          if (sessionsAsync.isLoading && !sessionsAsync.hasValue)
            const LinearProgressIndicator(),
            
          sessionsAsync.when(
            skipLoadingOnRefresh: true, // Standard Riverpod pattern for silent refresh
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
            loading: () => const SizedBox.shrink(), // Handled by the top indicator
            error: (err, stack) => SyncErrorWidget(
              message: 'Failed to load sessions',
              onRetry: () => ref.invalidate(sessionProvider),
            ),
          ),
          const Divider(),
          
          Expanded(
            child: activeSession == null
                ? const Center(child: Text('Select a session to view analytics'))
                : analytics.isEmpty
                    ? const Center(child: Text('No runs recorded for this session'))
                    : ListView.builder(
                        itemCount: analytics.length,
                        itemBuilder: (context, index) {
                          final item = analytics[index];
                          final isFastest = index == 0;
                          return _AnalyticsCard(item: item, index: index, isFastest: isFastest);
                        },
                      ),
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
