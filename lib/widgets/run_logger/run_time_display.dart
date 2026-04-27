import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/run_logger_controller.dart';

class RunTimeDisplay extends ConsumerWidget {
  const RunTimeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeDisplayStr = ref.watch(runLoggerControllerProvider.select((s) => s.timeInput));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          const Text(
            'Run Time (s)',
            style: TextStyle(
                fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              timeDisplayStr.isEmpty ? '00.00' : timeDisplayStr,
              style: const TextStyle(
                fontSize: 40,
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
