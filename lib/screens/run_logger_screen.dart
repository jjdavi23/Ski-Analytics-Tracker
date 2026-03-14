import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart';

class RunLoggerScreen extends ConsumerWidget {
  const RunLoggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Logger'),
      ),
      body: Column(
        children: [
          // Session Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TrainingSession>(
                    value: activeSession,
                    decoration: const InputDecoration(
                      labelText: 'Active Session',
                      border: OutlineInputBorder(),
                    ),
                    items: sessions.map((session) {
                      return DropdownMenuItem(
                        value: session,
                        child: Text('${session.location} (${session.snowCondition})'),
                      );
                    }).toList(),
                    onChanged: (session) {
                      if (session != null) {
                        ref.read(activeSessionProvider.notifier).state = session;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => _showCreateSessionDialog(context, ref),
                  tooltip: 'Create New Session',
                ),
              ],
            ),
          ),
          const Divider(),
          const Expanded(
            child: Center(
              child: Text('Numpad and Run Logger content will go here (Steps 2.3d/e)'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context, WidgetRef ref) {
    final locationController = TextEditingController();
    final snowConditionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Training Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: snowConditionController,
                decoration: const InputDecoration(labelText: 'Snow Condition (e.g., Icy)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (locationController.text.isNotEmpty && snowConditionController.text.isNotEmpty) {
                  final newSession = TrainingSession(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now(),
                    location: locationController.text,
                    snowCondition: snowConditionController.text,
                  );
                  ref.read(sessionProvider.notifier).addSession(newSession);
                  ref.read(activeSessionProvider.notifier).state = newSession;
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
