import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of an auth operation. Check [success] first — when it's false,
/// [error] holds a message that's safe to show directly to the user.
class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  const AuthResult.success([this.user])
      : success = true,
        error = null;

  const AuthResult.failure(this.error)
      : success = false,
        user = null;
}

/// Thin wrapper around Supabase Auth used by every sign-up, sign-in, and
/// account screen. Routing all calls through here means the UI never
/// talks to Supabase directly — handy if you ever swap providers, or want
/// a single place to add logging/analytics around auth events.
class AuthService {
  AuthService._();

  static GoTrueClient get _auth => Supabase.instance.client.auth;

  /// The current signed-in user, or null if signed out.
  static User? get currentUser => _auth.currentUser;

  /// The current session, or null if there is none.
  static Session? get currentSession => _auth.currentSession;

  static Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {'username': username.trim()},
      );
      if (response.user == null) {
        return const AuthResult.failure('We could not create your account. Please try again.');
      }
      return AuthResult.success(response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Check your connection and try again.');
    }
  }

  static Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        return const AuthResult.failure('Incorrect email or password.');
      }
      return AuthResult.success(response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Check your connection and try again.');
    }
  }

  /// Kicks off Google OAuth. On mobile this opens the system browser and
  /// completes via deep link; on web it redirects in place. A successful
  /// return here only means the flow *launched* — for a production app,
  /// also listen to `Supabase.instance.client.auth.onAuthStateChange` to
  /// react the moment the session actually lands back in the app.
  ///
  /// Setup required outside of Dart (per Supabase's docs):
  /// 1. Enable the Google provider in your Supabase dashboard.
  /// 2. Web: add every origin you actually run the app from (e.g.
  ///    `http://localhost:5000`, your deployed domain, etc.) to
  ///    Supabase Dashboard → Authentication → URL Configuration →
  ///    Redirect URLs. A wildcard like `http://localhost:*/**` covers
  ///    every port during local dev, so you don't need to pin one.
  ///    Mobile: register a redirect URL (e.g. io.blink.app://login-callback/)
  ///    with both Supabase and your Google Cloud OAuth client.
  /// 3. Add the matching URL scheme in Info.plist (iOS) and an
  ///    intent-filter in AndroidManifest.xml (Android).
  static Future<AuthResult> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        // FIX: passing `null` on web made Supabase fall back to the
        // dashboard's Site URL (often a stale/default localhost port),
        // not wherever the app is actually running — that mismatch is
        // exactly what produced "localhost refused to connect" after
        // Google's redirect back. Uri.base.origin is the page's real,
        // current origin, so the redirect always lands on a live server.
        redirectTo: kIsWeb ? Uri.base.origin : 'io.blink.app://login-callback/',
      );
      return const AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (_) {
      return const AuthResult.failure('Google sign-in failed. Please try again.');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}