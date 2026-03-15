import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../models/equipment_profile.dart';
import '../models/training_run.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/equipment_provider.dart';
import '../providers/run_provider.dart';
import '../widgets/numpad.dart';

class RunLoggerScreen extends ConsumerStatefulWidget {
  const RunLoggerScreen({super.key});

  @override
  ConsumerState<RunLoggerScreen> createState() => _RunLoggerScreenState();
}

class _RunLoggerScreenState extends ConsumerState<RunLoggerScreen> {
  String _timeInput = '';
  EquipmentProfile? _selectedEquipment;

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

  void _saveRun() {
    final activeSession = ref.read(activeSessionProvider);
    if (activeSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a session first.')),
      );
      return;
    }

    if (_selectedEquipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an equipment profile.')),
      );
      return;
    }

    final time = double.tryParse(_timeInput);
    if (time == null || time <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid time.')),
      );
      return;
    }

    final newRun = TrainingRun(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timeInSeconds: time,
      sessionId: activeSession.id,
      equipmentProfileId: _selectedEquipment!.id,
    );

    ref.read(runProvider.notifier).addRun(newRun);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Run saved successfully!')),
    );

    setState(() {
      _timeInput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final equipmentProfiles = ref.watch(equipmentProvider);

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
                          ref.read(activeSessionProvider.notifier).setSession(session);
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
                        fontFamily: 'Courier',
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
            
            // Equipment Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<EquipmentProfile>(
                value: _selectedEquipment,
                decoration: const InputDecoration(
                  labelText: 'Select Equipment',
                  border: OutlineInputBorder(),
                ),
                items: equipmentProfiles.map((profile) {
                  return DropdownMenuItem(
                    value: profile,
                    child: Text(profile.name),
                  );
                }).toList(),
                onChanged: (profile) {
                  setState(() {
                    _selectedEquipment = profile;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRun,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Run', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),

            const SizedBox(height: 40),
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
                  ref.read(activeSessionProvider.notifier).setSession(newSession);
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
