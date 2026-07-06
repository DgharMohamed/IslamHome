import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get userChanges => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  // ─── Anonymous Sign-In ──────────────────────────────────────────────

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('AuthService: signInAnonymously error: $e');
      return null;
    }
  }

  // ─── Email / Password ───────────────────────────────────────────────

  Future<UserCredential?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } catch (e) {
      debugPrint('AuthService: registerWithEmail error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('AuthService: loginWithEmail error: $e');
      rethrow;
    }
  }

  /// Links the current anonymous account to an email/password account.
  /// This preserves all UID-associated data in Firestore.
  Future<UserCredential?> linkAnonymousWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final result = await user.linkWithCredential(credential);

      if (result.user != null) {
        await result.user!.updateDisplayName(name);
      }

      return result;
    } catch (e) {
      debugPrint('AuthService: linkAnonymousWithEmail error: $e');
      rethrow;
    }
  }

  // ─── Google Sign-In ─────────────────────────────────────────────────

  /// Sign in with Google. Returns null if the user cancels the flow.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        try {
          return await currentUser.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code != 'credential-already-in-use' &&
              e.code != 'provider-already-linked') {
            rethrow;
          }
        }
      }

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('AuthService: signInWithGoogle error: $e');
      rethrow;
    }
  }

  /// Links the current anonymous account to a Google account.
  /// This preserves all UID-associated data in Firestore.
  Future<UserCredential?> linkAnonymousWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await user.linkWithCredential(credential);
    } catch (e) {
      debugPrint('AuthService: linkAnonymousWithGoogle error: $e');
      rethrow;
    }
  }

  // ─── Sign Out ───────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      // Auto sign back in anonymously to preserve local usage tracking
      await signInAnonymously();
    } catch (e) {
      debugPrint('AuthService: signOut error: $e');
    }
  }

  // ─── Account Management ─────────────────────────────────────────────

  Future<void> updateDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
      }
    } catch (e) {
      debugPrint('AuthService: updateDisplayName error: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        // After deletion, sign in anonymously again
        await signInAnonymously();
      }
    } catch (e) {
      debugPrint('AuthService: deleteAccount error: $e');
      rethrow;
    }
  }

  // ─── Password Reset ─────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('AuthService: sendPasswordResetEmail error: $e');
      rethrow;
    }
  }
}
