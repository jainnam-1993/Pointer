/// Auth providers - Firebase Authentication state management
///
/// Manages user authentication state for cross-platform purchase sync.
/// Auth is OPTIONAL - app works fully anonymously until user signs in.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

// ============================================================
// Auth Service Singleton
// ============================================================

/// Auth service provider - singleton instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

// ============================================================
// Auth State Stream
// ============================================================

/// Stream of Firebase auth state changes
///
/// Emits:
/// - User object when signed in
/// - null when signed out
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// ============================================================
// Convenience Providers
// ============================================================

/// Whether user is currently signed in
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// Current user's display name (from Google/Apple profile)
final userDisplayNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.displayName;
});

/// Current user's email
final userEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.email;
});

/// Current user's UID (null if not signed in)
final userUidProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});

// ============================================================
// Auth Actions Notifier
// ============================================================

/// State for auth operations (loading, error handling)
class AuthActionState {
  final bool isLoading;
  final String? error;

  const AuthActionState({
    this.isLoading = false,
    this.error,
  });

  AuthActionState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for auth actions (sign in, sign out)
class AuthActionNotifier extends StateNotifier<AuthActionState> {
  final AuthService _authService;

  AuthActionNotifier(this._authService) : super(const AuthActionState());

  /// Sign in with Google
  ///
  /// Returns true on success, false on cancel/error.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithGoogle();
      state = state.copyWith(isLoading: false);
      return user != null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Sign in with Apple
  ///
  /// Returns true on success, false on cancel/error.
  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithApple();
      state = state.copyWith(isLoading: false);
      return user != null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method';
        case 'invalid-credential':
          return 'Invalid credentials. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'user-not-found':
          return 'No account found';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'Sign in failed. Please try again.';
      }
    }
    return 'An error occurred. Please try again.';
  }
}

/// Provider for auth actions (sign in, sign out with loading/error state)
final authActionProvider =
    StateNotifierProvider<AuthActionNotifier, AuthActionState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthActionNotifier(authService);
});
