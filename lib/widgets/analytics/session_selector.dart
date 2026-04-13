import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/session_provider.dart';
import '../../providers/active_session_provider.dart';
import '../sync_error_widget.dart';

class SessionSelector extends ConsumerWidget {
  const SessionSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionProvider);
    final sessionId = ref.watch(sessionIdProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return Column(
      children: [
        if (sessionsAsync.isLoading && !sessionsAsync.hasValue)
          const LinearProgressIndicator(),
        sessionsAsync.when(
          skipLoadingOnRefresh: true,
          data: (sessions) {
            // Determine the value to show in the dropdown
            final dropdownValue = sessionId == 'all_time' 
                ? 'all_time'
                : (sessions.any((s) => s.id == activeSession?.id) ? activeSession?.id : null);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: const InputDecoration(
                  labelText: 'Select Training Session',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'all_time',
                    child: Text('All Time'),
                  ),
                  ...sessions.map((session) {
                    return DropdownMenuItem(
                      value: session.id,
                      child: Text(
                          '${session.location} (${session.date.month}/${session.date.day})'),
                    );
                  }).toList(),
                ],
                onChanged: (id) {
                  if (id != null) {
                    ref.read(sessionIdProvider.notifier).setSessionId(id);
                  }
                },
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => SyncErrorWidget(
            message: 'Failed to load sessions',
            onRetry: () => ref.invalidate(sessionProvider),
          ),
        ),
      ],
    );
  }
}
