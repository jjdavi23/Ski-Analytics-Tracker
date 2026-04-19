import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart'; // Reusing authServiceProvider for now

class AuthNotifier extends StreamNotifier<User?> {
  @override
  Stream<User?> build() {
    return ref.watch(authServiceProvider).user;
  }

  // Proxy methods to AuthService via authServiceProvider
  
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithEmail(email, password);
      // State will be updated automatically by the stream in build()
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).registerWithEmail(email, password);
      // State will be updated automatically by the stream in build()
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // State will be updated automatically by the stream in build()
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signOut();
      // State will be updated automatically by the stream in build()
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

final authProvider = StreamNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});
