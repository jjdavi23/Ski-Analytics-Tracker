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
import '../controllers/run_logger_controller.dart';

class RunLoggerScreen extends ConsumerWidget {
  const RunLoggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final equipmentProfiles = ref.watch(equipmentProvider);
    final loggerState = ref.watch(runLoggerControllerProvider);
    final loggerNotifier = ref.read(runLoggerControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Logger'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Session Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TrainingSession>(
                      value: activeSession,
                      decoration: const InputDecoration(
                        labelText: 'Active Session',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                children: [
                  const Text(
                    'Run Time (s)',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loggerState.timeInput.isEmpty ? '00.00' : loggerState.timeInput,
                      style: const TextStyle(
                        fontSize: 40,
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
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: NumpadWidget(
                onKeyPressed: loggerNotifier.handleKeyPress,
                onDeletePressed: loggerNotifier.handleDelete,
                onClearPressed: loggerNotifier.handleClear,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Equipment Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<EquipmentProfile>(
                value: loggerState.selectedEquipment,
                decoration: const InputDecoration(
                  labelText: 'Select Equipment',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(),
                ),
                items: equipmentProfiles.map((profile) {
                  return DropdownMenuItem(
                    value: profile,
                    child: Text(profile.name),
                  );
                }).toList(),
                onChanged: (profile) {
                  loggerNotifier.setSelectedEquipment(profile);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final errorMessage = loggerNotifier.saveRun();
                    
                    if (errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Run saved successfully!'), 
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage), 
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Save Run', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),

            const SizedBox(height: 20),
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
