import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/training_session.dart';
import '../../providers/session_provider.dart';
import '../../providers/active_session_provider.dart';

class SessionSelector extends ConsumerWidget {
  const SessionSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: sessionsAsync.when(
              skipLoadingOnRefresh: true,
              data: (sessions) => DropdownButtonFormField<String>(
                value: sessions.any((s) => s.id == activeSession?.id)
                    ? activeSession?.id
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Active Session',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(),
                ),
                items: sessions.map((session) {
                  return DropdownMenuItem(
                    value: session.id,
                    child: Text(
                        '${session.location} (${session.snowCondition})'),
                  );
                }).toList(),
                onChanged: (sessionId) {
                  if (sessionId != null) {
                    ref.read(sessionIdProvider.notifier).setSessionId(sessionId);
                  }
                },
              ),
              loading: () => const Text('Loading sessions...'),
              error: (e, st) => const Text('Error loading sessions'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blueGrey),
            onPressed: () {
              Future.microtask(() => _showCreateSessionDialog(context, ref));
            },
            tooltip: 'Create New Session',
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
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Training Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration:
                    const InputDecoration(labelText: 'Location (e.g. Whiteface)'),
              ),
              TextField(
                controller: snowConditionController,
                decoration:
                    const InputDecoration(labelText: 'Snow (e.g. Firm/Icy)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (locationController.text.isNotEmpty &&
                    snowConditionController.text.isNotEmpty) {
                  final newSession = TrainingSession(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now(),
                    location: locationController.text,
                    snowCondition: snowConditionController.text,
                  );

                  ref.read(sessionProvider.notifier).addSession(newSession);
                  ref
                      .read(sessionIdProvider.notifier)
                      .setSessionId(newSession.id);

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
