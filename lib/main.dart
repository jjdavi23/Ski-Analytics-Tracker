import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- NEW IMPORT
import 'firebase_options.dart';
import 'widgets/auth_gate.dart';
import 'providers/shared_preferences_provider.dart';

void main() async {
  print("🎿 DEBUG: Main started..."); 
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🎿 DEBUG: Firebase Connected");

    // --- TURBO CHARGE START ---
    // This makes your dropdowns load in 1 second instead of 30.
    // It loads the last known data from local storage while syncing in the background.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, 
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print("🎿 DEBUG: Firestore Persistence Enabled");
    // --- TURBO CHARGE END ---

    final sharedPrefs = await SharedPreferences.getInstance();
    
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const MyApp(),
      ),
    );
    
  } catch (e, stack) {
    print("❌ FATAL ERROR: $e");
    print(stack);
  }
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
      home: const AuthGate(), 
    );
  }
} 