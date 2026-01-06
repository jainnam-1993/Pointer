import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Service for managing Firebase Authentication.
///
/// Handles:
/// - Firebase initialization
/// - Google Sign-In
/// - Apple Sign-In
/// - Auth state management
/// - RevenueCat user identity sync (via callback)
class AuthService {
  static AuthService? _instance;
  bool _isInitialized = false;

  /// Callback invoked when user signs in (with Firebase UID)
  /// Used to sync RevenueCat identity
  void Function(String uid)? onSignIn;

  /// Callback invoked when user signs out
  /// Used to reset RevenueCat to anonymous
  void Function()? onSignOut;

  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Initialize Firebase. Must be called before any other Firebase services.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Firebase.initializeApp();
    _isInitialized = true;
    print('[AuthService] Firebase initialized');

    // If user is already signed in, notify callback
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      print('[AuthService] User already signed in: ${currentUser.uid}');
      onSignIn?.call(currentUser.uid);
    }
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current signed-in user (null if anonymous)
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// User's display name (from Google/Apple profile)
  String? get displayName => _auth.currentUser?.displayName;

  /// User's email
  String? get email => _auth.currentUser?.email;

  /// Sign in with Google
  ///
  /// Returns the User on success, null on cancellation.
  /// Throws on error.
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // User cancelled
      if (googleUser == null) {
        print('[AuthService] Google sign-in cancelled');
        return null;
      }

      // Get auth details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print('[AuthService] Google sign-in success: ${user.uid}');
        onSignIn?.call(user.uid);
      }

      return user;
    } catch (e) {
      print('[AuthService] Google sign-in error: $e');
      rethrow;
    }
  }

  /// Sign in with Apple
  ///
  /// Returns the User on success, null on cancellation.
  /// Throws on error.
  Future<User?> signInWithApple() async {
    try {
      // Request Apple credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create Firebase credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      // Apple only provides name on first sign-in, update profile if available
      if (user != null && appleCredential.givenName != null) {
        final displayName =
            '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
      }

      if (user != null) {
        print('[AuthService] Apple sign-in success: ${user.uid}');
        onSignIn?.call(user.uid);
      }

      return user;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        print('[AuthService] Apple sign-in cancelled');
        return null;
      }
      print('[AuthService] Apple sign-in error: $e');
      rethrow;
    } catch (e) {
      print('[AuthService] Apple sign-in error: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      await GoogleSignIn().signOut();

      // Sign out from Firebase
      await _auth.signOut();

      print('[AuthService] Signed out');
      onSignOut?.call();
    } catch (e) {
      print('[AuthService] Sign out error: $e');
      rethrow;
    }
  }

  /// Check if Apple Sign-In is available (iOS only, iOS 13+)
  Future<bool> isAppleSignInAvailable() async {
    if (!Platform.isIOS) return false;
    return await SignInWithApple.isAvailable();
  }

  /// Delete the current user's account
  ///
  /// Warning: This is irreversible. The user will need to re-purchase.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
      print('[AuthService] Account deleted');
      onSignOut?.call();
    } catch (e) {
      print('[AuthService] Delete account error: $e');
      rethrow;
    }
  }
}

/// Result of an auth operation
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final bool isCancelled;

  const AuthResult({
    required this.success,
    this.user,
    this.error,
    this.isCancelled = false,
  });

  factory AuthResult.success(User user) => AuthResult(
        success: true,
        user: user,
      );

  factory AuthResult.cancelled() => const AuthResult(
        success: false,
        isCancelled: true,
      );

  factory AuthResult.error(String message) => AuthResult(
        success: false,
        error: message,
      );
}
