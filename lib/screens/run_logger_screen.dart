import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../models/equipment_profile.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart'; 
import '../providers/equipment_provider.dart';
import '../widgets/numpad.dart';
import '../widgets/sync_error_widget.dart';
import '../controllers/run_logger_controller.dart';

class RunLoggerScreen extends ConsumerWidget {
  const RunLoggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data Streams
    final sessionsAsync = ref.watch(sessionProvider);
    final equipmentProfilesAsync = ref.watch(equipmentProvider);
    final activeSession = ref.watch(activeSessionProvider);
    
    // 2. Performance Optimization: Only watch timeInput for the display.
    final timeDisplayStr = ref.watch(runLoggerControllerProvider.select((s) => s.timeInput));
    
    // 3. Watch the full state for the Save Button's logic
    final loggerState = ref.watch(runLoggerControllerProvider);
    final loggerNotifier = ref.read(runLoggerControllerProvider.notifier);

    // Global loading indicator
    final bool isGlobalLoading = (sessionsAsync.isLoading && !sessionsAsync.hasValue) || 
                                (equipmentProfilesAsync.isLoading && !equipmentProfilesAsync.hasValue);

    // Global error check
    if (sessionsAsync.hasError || equipmentProfilesAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Run Logger')),
        body: SyncErrorWidget(
          message: 'Connection issues on the mountain',
          onRetry: () {
            ref.invalidate(sessionProvider);
            ref.invalidate(equipmentProvider);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Logger'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isGlobalLoading) const LinearProgressIndicator(),
            
            // --- Session Selector ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: sessionsAsync.when(
                      skipLoadingOnRefresh: true,
                      data: (sessions) => _buildSessionDropdown(context, ref, sessions, activeSession),
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
            ),
            const Divider(),
            
            // --- Time Display ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  const Text(
                    'Run Time (s)',
                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      timeDisplayStr.isEmpty ? '00.00' : timeDisplayStr,
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

            // --- Numpad ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: NumpadWidget(
                onKeyPressed: loggerNotifier.handleKeyPress,
                onDeletePressed: loggerNotifier.handleDelete,
                onClearPressed: loggerNotifier.handleClear,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // --- Equipment Selector ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: equipmentProfilesAsync.when(
                skipLoadingOnRefresh: true,
                data: (profiles) => _buildEquipmentDropdown(ref, profiles, loggerState),
                loading: () => const Text('Loading equipment...'),
                error: (e, st) => const Text('Error loading equipment'),
              ),
            ),

            const SizedBox(height: 24),

            // --- Save Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (activeSession == null || loggerState.isLoading) ? null : () async {
                    final errorMessage = await loggerNotifier.saveRun();
                    
                    if (context.mounted) {
                      if (errorMessage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Run logged!'), 
                            backgroundColor: Colors.green,
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: loggerState.isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('Save Run', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            if (activeSession == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("Select a session before saving", style: TextStyle(color: Colors.red, fontSize: 12)),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper: Session Dropdown UI ---
  Widget _buildSessionDropdown(BuildContext context, WidgetRef ref, List<TrainingSession> sessions, TrainingSession? activeSession) {
    return DropdownButtonFormField<String>(
      value: sessions.any((s) => s.id == activeSession?.id) ? activeSession?.id : null,
      decoration: const InputDecoration(
        labelText: 'Active Session',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(),
      ),
      items: sessions.map((session) {
        return DropdownMenuItem(
          value: session.id,
          child: Text('${session.location} (${session.snowCondition})'),
        );
      }).toList(),
      onChanged: (sessionId) {
        if (sessionId != null) {
          ref.read(sessionIdProvider.notifier).setSessionId(sessionId);
        }
      },
    );
  }

  // --- Helper: Equipment Dropdown UI ---
  Widget _buildEquipmentDropdown(WidgetRef ref, List<EquipmentProfile> profiles, RunLoggerState loggerState) {
    final bool exists = profiles.any((p) => p.id == loggerState.selectedEquipmentId);
    
    return DropdownButtonFormField<String>(
      value: exists ? loggerState.selectedEquipmentId : null,
      decoration: const InputDecoration(
        labelText: 'Select Equipment',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(),
      ),
      items: profiles.map((profile) {
        return DropdownMenuItem(
          value: profile.id,
          child: Text(profile.name),
        );
      }).toList(),
      onChanged: (equipmentId) {
        ref.read(runLoggerControllerProvider.notifier).setSelectedEquipmentId(equipmentId);
      },
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
                decoration: const InputDecoration(labelText: 'Location (e.g. Whiteface)'),
              ),
              TextField(
                controller: snowConditionController,
                decoration: const InputDecoration(labelText: 'Snow (e.g. Firm/Icy)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
                  ref.read(sessionIdProvider.notifier).setSessionId(newSession.id);
                  
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
