import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error, // If we pass null, it clears the error
    );
  }
}

final authControllerProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initialize state and listen to auth changes
    final authService = ref.watch(authServiceProvider);
    
    // We can't use an async listen here directly in build, 
    // but we can initialize with the current user
    return AuthState(user: FirebaseAuth.instance.currentUser);
  }

  // Helper to update state with loading
  void _setLoading() {
    state = state.copyWith(isLoading: true, error: null);
  }

  // Helper to update state with error
  void _setError(String message) {
    state = state.copyWith(isLoading: false, error: message);
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading();
    try {
      final result = await ref.read(authServiceProvider).signInWithEmail(email, password);
      state = state.copyWith(user: result?.user, isLoading: false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    _setLoading();
    try {
      final result = await ref.read(authServiceProvider).registerWithEmail(email, password);
      state = state.copyWith(user: result?.user, isLoading: false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading();
    try {
      final result = await ref.read(authServiceProvider).signInWithGoogle();
      state = state.copyWith(user: result?.user, isLoading: false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signOut() async {
    _setLoading();
    try {
      await ref.read(authServiceProvider).signOut();
      state = AuthState(); // Reset state
    } catch (e) {
      _setError(e.toString());
    }
  }

  // This should be called by the AuthGate or main entry point 
  // to sync the User object whenever Firebase confirms a change
  void onAuthStateChanged(User? user) {
    state = state.copyWith(user: user, isLoading: false);
  }
}
