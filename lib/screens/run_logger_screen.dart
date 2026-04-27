import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../providers/equipment_provider.dart';
import '../widgets/numpad.dart';
import '../widgets/sync_error_widget.dart';
import '../widgets/run_logger/session_selector.dart' as logger;
import '../widgets/run_logger/run_time_display.dart';
import '../widgets/run_logger/equipment_selector.dart';
import '../widgets/run_logger/save_run_button.dart';
import '../controllers/run_logger_controller.dart';

class RunLoggerScreen extends ConsumerWidget {
  const RunLoggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data Streams
    final sessionsAsync = ref.watch(sessionProvider);
    final equipmentProfilesAsync = ref.watch(equipmentProvider);
    
    // 2. Watch the full state for the Controller logic
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
            
            const SizedBox(height: 12),
            
            // --- Equipment Selector ---
            const EquipmentSelector(),

            const SizedBox(height: 12),

            // --- Save Button ---
            const SaveRunButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
