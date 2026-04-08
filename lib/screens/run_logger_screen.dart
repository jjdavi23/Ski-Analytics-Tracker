import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart'; 
import '../providers/equipment_provider.dart';
import '../widgets/numpad.dart';
import '../widgets/sync_error_widget.dart';
import '../widgets/run_logger/session_selector.dart' as logger;
import '../widgets/run_logger/run_time_display.dart';
import '../widgets/run_logger/equipment_selector.dart';
import '../controllers/run_logger_controller.dart';

class RunLoggerScreen extends ConsumerWidget {
  const RunLoggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data Streams
    final sessionsAsync = ref.watch(sessionProvider);
    final equipmentProfilesAsync = ref.watch(equipmentProvider);
    final activeSession = ref.watch(activeSessionProvider);
    
    // 2. Watch the full state for the Save Button's logic
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
            const logger.SessionSelector(),
            const Divider(),
            
            // --- Time Display ---
            const RunTimeDisplay(),

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
            const EquipmentSelector(),

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
}
