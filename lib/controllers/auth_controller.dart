import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

//service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

//auth Stream Provider (The AuthGate will listen to this to know when to show the Login screen)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).user;
});

//controller State (Only handles loading UI now)
class AuthControllerState {
  final bool isLoading;
  AuthControllerState({this.isLoading = false});
}

//controller Provider
final authControllerProvider = NotifierProvider<AuthNotifier, AuthControllerState>(() {
  return AuthNotifier();
});

//the Controller
class AuthNotifier extends Notifier<AuthControllerState> {
  @override
  AuthControllerState build() {
    return AuthControllerState(); // Starts not loading
  }

  //helper to trigger loading spinners
  void _setLoading(bool loading) {
    state = AuthControllerState(isLoading: loading);
  }

  //notice how these now return Future<String?> 
  //null = success
  //string = The clean error message to show in the UI SnackBar
  Future<String?> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await ref.read(authServiceProvider).signInWithEmail(email, password);
      _setLoading(false);
      return null; 
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Login failed. Please try again.';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<String?> registerWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await ref.read(authServiceProvider).registerWithEmail(email, password);
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Registration failed. Please try again.';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Google Sign-In failed.';
    } catch (e) {
      _setLoading(false);
      return 'Google Sign-In was canceled or failed.';
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await ref.read(authServiceProvider).signOut();
    _setLoading(false);
  }
}