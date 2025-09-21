// lib/services/social_auth_service.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthService {
  SocialAuthService._();
  static final SocialAuthService instance = SocialAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn(scopes: const ['email']);

  /// Google Sign-In
  /// - Web: uses Firebase `signInWithPopup`
  /// - Android/iOS: uses google_sign_in, then bridges to Firebase
  Future<UserCredential> signInWithGoogle({
    String? clientId, // iOS/macOS OAuth client ID (NOT reversed)
    String?
    serverClientId, // optional Web App client ID if you do backend exchange
  }) async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _auth.signInWithPopup(provider);
    }

    // Optionally initialize with IDs (mainly for iOS/macOS; Android usually fine without)

    final GoogleSignInAccount? account = await _google.signIn();
    if (account == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  /// Facebook Sign-In
  /// - Web: uses Firebase `signInWithPopup`
  /// - Android/iOS: uses flutter_facebook_auth, then bridges to Firebase
  Future<UserCredential> signInWithFacebook() async {
    if (kIsWeb) {
      final provider = FacebookAuthProvider();
      return _auth.signInWithPopup(provider);
    }

    final LoginResult result = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
    );

    switch (result.status) {
      case LoginStatus.success:
        final String token =
            result.accessToken!.tokenString; // tokenString in older versions
        final credential = FacebookAuthProvider.credential(token);
        return _auth.signInWithCredential(credential);

      case LoginStatus.cancelled:
        throw Exception('Facebook sign-in cancelled');

      case LoginStatus.failed:
      default:
        throw Exception(result.message ?? 'Facebook sign-in failed');
    }
  }

  Future<UserCredential> signInWithAppleWeb() async {
    final provider = OAuthProvider('apple.com')
      ..addScope('email')
      ..addScope('name')
      ..setCustomParameters({'locale': 'en'}); // optional

    if (!kIsWeb) {
      throw Exception(
        'Use native Apple flow on iOS/macOS, not this web method.',
      );
    }

    try {
      return await _auth.signInWithPopup(provider);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-blocked' || e.code == 'web-context-canceled') {
        await FirebaseAuth.instance.signInWithRedirect(provider);
        throw Exception('Redirecting for Apple sign-in…');
      }
      rethrow;
    }
  }

  Future<UserCredential> signInWithApple() async {
    if (kIsWeb) {
      final provider = OAuthProvider('apple.com');
      provider.addScope('email');
      provider.addScope('name');
      provider.setCustomParameters({'locale': 'en'}); // optional

      try {
        return await FirebaseAuth.instance.signInWithPopup(provider);
      } on FirebaseAuthException catch (e) {
        // Popup blocked or context lost? Use redirect flow.
        if (e.code == 'popup-blocked' || e.code == 'web-context-canceled') {
          await FirebaseAuth.instance.signInWithRedirect(provider);
          // App will reload; later you can read the result:
          // final result = await FirebaseAuth.instance.getRedirectResult();
          // return result;
          // For now, return a future that never completes since the page redirects.
          // (You can also re-architect to await getRedirectResult() on app start.)
          throw Exception('Redirecting for Apple sign-in…');
        }
        rethrow;
      }
    }

    if (!Platform.isIOS && !Platform.isMacOS) {
      throw Exception('Apple Sign-In is only available on iOS/macOS');
    }

    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      // For web you’d need webAuthenticationOptions, but we’re limiting to iOS/macOS here.
    );

    final oauth = OAuthProvider('apple.com').credential(
      idToken: appleCred.identityToken,
      accessToken: appleCred.authorizationCode, // acceptable for Firebase
    );

    final userCred = await _auth.signInWithCredential(oauth);

    // Optional: set display name on first sign-in if provided
    final fullName = [
      appleCred.givenName ?? '',
      appleCred.familyName ?? '',
    ].where((s) => s.isNotEmpty).join(' ');
    if (fullName.isNotEmpty &&
        userCred.user != null &&
        (userCred.user!.displayName == null ||
            userCred.user!.displayName!.isEmpty)) {
      await userCred.user!.updateDisplayName(fullName);
    }

    return userCred;
  }

  /// Global sign-out (best effort)
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _google.signOut();
      } catch (_) {}
      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }
}
