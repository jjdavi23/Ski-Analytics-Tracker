import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/run_logger_screen.dart'; // Pointing to your new screen!

void main() {
  // ProviderScope is the Riverpod "radio tower" that powers your whole app
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ski Racing Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      // THIS is the magic line. We are setting your Run Logger as the home screen!
      home: const RunLoggerScreen(), 
    );
  }
}