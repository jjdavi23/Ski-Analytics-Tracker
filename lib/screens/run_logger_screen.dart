import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart';
import '../widgets/numpad.dart';

class RunLoggerScreen extends ConsumerStatefulWidget {
  const RunLoggerScreen({super.key});

  @override
  ConsumerState<RunLoggerScreen> createState() => _RunLoggerScreenState();
}

class _RunLoggerScreenState extends ConsumerState<RunLoggerScreen> {
  String _timeInput = '';

  void _handleKeyPress(String key) {
    setState(() {
      if (key == '.' && _timeInput.contains('.')) return;
      if (_timeInput.contains('.') && _timeInput.split('.')[1].length >= 2) return;
      _timeInput += key;
    });
  }

  void _handleDelete() {
    setState(() {
      if (_timeInput.isNotEmpty) {
        _timeInput = _timeInput.substring(0, _timeInput.length - 1);
      }
    });
  }

  void _handleClear() {
    setState(() {
      _timeInput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Logger'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            
            // Time Display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  const Text(
                    'Run Time (s)',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _timeInput.isEmpty ? '00.00' : _timeInput,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier', // Monospace for stability
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Numpad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: NumpadWidget(
                onKeyPressed: _handleKeyPress,
                onDeletePressed: _handleDelete,
                onClearPressed: _handleClear,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Equipment selection and Save will go here (Step 2.3e)'),
            ),
          ],
        ),
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
