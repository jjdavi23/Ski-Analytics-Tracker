import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: Column(
        children: [
          // Session Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<TrainingSession>(
              value: activeSession,
              decoration: const InputDecoration(
                labelText: 'Select Training Session',
                border: OutlineInputBorder(),
              ),
              items: sessions.map((session) {
                return DropdownMenuItem(
                  value: session,
                  child: Text('${session.location} - ${session.snowCondition} (${session.date.month}/${session.date.day})'),
                );
              }).toList(),
              onChanged: (session) {
                if (session != null) {
                  ref.read(activeSessionProvider.notifier).setSession(session);
                }
              },
            ),
          ),
          const Divider(),
          
          // Analytics List
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
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: isFastest ? Colors.green.withOpacity(0.1) : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isFastest ? Colors.green : Colors.blue,
                                child: Text('#${index + 1}', style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(
                                item.equipment.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${item.runCount} runs • ${item.equipment.description}'),
                              trailing: Text(
                                '${item.averageTime.toStringAsFixed(2)}s',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
