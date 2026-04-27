import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/active_session_provider.dart';
import '../../controllers/run_logger_controller.dart';

class SaveRunButton extends ConsumerWidget {
  const SaveRunButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final loggerState = ref.watch(runLoggerControllerProvider);
    final loggerNotifier = ref.read(runLoggerControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: (activeSession == null || loggerState.isLoading)
                  ? null
                  : () async {
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
                            SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: loggerState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Run',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        if (activeSession == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text("Select a session before saving",
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }
}
