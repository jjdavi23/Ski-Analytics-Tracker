import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/run_logger_controller.dart';

class RunTimeDisplay extends ConsumerWidget {
  const RunTimeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeDisplayStr = ref.watch(runLoggerControllerProvider.select((s) => s.timeInput));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          const Text(
            'Run Time (s)',
            style: TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              timeDisplayStr.isEmpty ? '00.00' : timeDisplayStr,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
