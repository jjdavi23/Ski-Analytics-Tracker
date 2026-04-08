import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart'; // Or wherever your home is

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to the auth state (Live from Firebase)
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Case A: We found a user (or didn't)
      data: (user) {
        if (user != null) {
          return const MainScreen(); // Logged in!
        }
        return const LoginScreen(); // Not logged in!
      },
      
      // Case B: Firebase is still "thinking" (This is usually the blank screen culprit)
      loading: () => const Scaffold(
        backgroundColor: Colors.blueGrey, // A distinct color so we know it's loading
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text("Checking Ski Credentials...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),

      // Case C: Something went wrong
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Auth Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}