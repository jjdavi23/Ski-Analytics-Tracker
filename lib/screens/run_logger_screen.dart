import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunLoggerScreen extends ConsumerStatefulWidget {
  const RunLoggerScreen({super.key});

  @override
  ConsumerState<RunLoggerScreen> createState() => _RunLoggerScreenState();
}

class _RunLoggerScreenState extends ConsumerState<RunLoggerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Logger'),
      ),
      body: const Center(
        child: Text('Run Logger Screen Placeholder'),
      ),
    );
  }
}
