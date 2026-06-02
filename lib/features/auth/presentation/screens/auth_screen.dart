import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/user_profile_service.dart';

// Web client ID from google-services.json (oauth_client type 3).
// Required on Android so GoogleSignIn can produce a valid idToken for Firebase.
const _kGoogleWebClientId =
    '772109770995-dbc56ba1adcr5sdnpn9rhe8daajm13gk.apps.googleusercontent.com';

class AuthScreen extends StatefulWidget {
  /// When true, links credentials to the current anonymous account instead of
  /// creating a new session — used when a guest user chooses to sign in.
  const AuthScreen({super.key, this.isLinking = false});

  final bool isLinking;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _applyCredential(
    AuthCredential credential, {
    String? displayName,
    String? email,
    String? photoUrl,
  }) async {
    final auth = FirebaseAuth.instance;
    try {
      if (widget.isLinking && auth.currentUser != null) {
        await auth.currentUser!.linkWithCredential(credential);
        if (mounted) Navigator.of(context).pop();
      } else {
        await auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      // Guest upgrade: Google/Apple account already exists as a separate user.
      // Sign in to that account instead of linking to the anonymous session.
      final recoverable = e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use' ||
          e.code == 'account-exists-with-different-credential' ||
          e.code == 'provider-already-linked';
      if (widget.isLinking && recoverable) {
        // provider-already-linked: anonymous account already has this provider.
        // Sign in with the credential to resolve to the full account.
        final existingCredential = e.credential ?? credential;
        await auth.signInWithCredential(existingCredential);
        if (mounted) Navigator.of(context).pop();
        return;
      }
      rethrow;
    }
    final user = auth.currentUser;
    if (user == null || user.isAnonymous) return;
    if (displayName != null &&
        displayName.isNotEmpty &&
        user.displayName != displayName) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null && photoUrl.isNotEmpty && user.photoURL != photoUrl) {
      await user.updatePhotoURL(photoUrl);
    }
    await UserProfileService.instance.captureAndSync(
      user,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
    );
  }

  String _authErrorMessage(Object e, {required String provider}) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'credential-already-in-use':
        case 'email-already-in-use':
          return 'This $provider account is already registered. '
              'We signed you in to your existing account.';
        case 'account-exists-with-different-credential':
          return 'An account with this email already exists. '
              'Try signing in with the method you used originally.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        case 'popup-closed-by-user':
        case 'cancelled':
          return '';
        default:
          break;
      }
    }
    final detail = kDebugMode ? '\n\nDebug: $e' : '';
    return '$provider sign-in failed. Please try again.$detail';
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final googleSignIn = GoogleSignIn(serverClientId: _kGoogleWebClientId);
      // Sign out of any cached session so the account picker always appears,
      // letting the user choose a different Google account if they wish.
      await googleSignIn.signOut();
      final gUser = await googleSignIn.signIn();
      if (gUser == null) {
        // User cancelled the picker — not an error.
        setState(() => _loading = false);
        return;
      }
      final gAuth = await gUser.authentication;
      if (gAuth.idToken == null) {
        setState(() {
          _error = 'Google sign-in did not return a valid token. '
              'Make sure the SHA-1 fingerprint is registered in Firebase Console '
              'and Google Sign-In is enabled in Authentication → Sign-in method.';
          _loading = false;
        });
        return;
      }
      await _applyCredential(
        GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        ),
        displayName: gUser.displayName,
        email: gUser.email,
        photoUrl: gUser.photoUrl,
      );
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      final msg = _authErrorMessage(e, provider: 'Google');
      setState(() {
        _error = msg.isEmpty ? null : msg;
        _loading = false;
      });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );
      await _applyCredential(OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      ));
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      final msg = _authErrorMessage(e, provider: 'Apple');
      setState(() {
        _error = msg.isEmpty ? null : msg;
        _loading = false;
      });
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      setState(() {
        _error = 'Could not start guest session.';
        _loading = false;
      });
    }
  }

  Future<void> _signInWithEmail() async {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isRegister = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isRegister ? 'Create Account' : 'Sign In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setDialogState(() => isRegister = !isRegister),
                child: Text(isRegister
                    ? 'Already have an account? Sign in'
                    : 'No account? Create one'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (isRegister) {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailCtrl.text.trim(), password: passCtrl.text);
                  } else {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailCtrl.text.trim(), password: passCtrl.text);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: Text(isRegister ? 'Create Account' : 'Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.auto_graph_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome',
                style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isLinking
                    ? 'Sign in to sync your data across all devices.'
                    : 'Track your budget. Sign in to sync, or continue as guest.',
                style:
                    theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
              ),
              const Spacer(),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!,
                        style: TextStyle(color: Colors.red.shade800)),
                  ),
                if (_error != null) const SizedBox(height: 12),
                _SocialButton(
                  onPressed: _signInWithGoogle,
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  color: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.black12,
                ),
                const SizedBox(height: 12),
                _SocialButton(
                  onPressed: _signInWithApple,
                  label: 'Continue with Apple',
                  icon: Icons.apple_rounded,
                  color: Colors.black,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 12),
                _SocialButton(
                  onPressed: _signInWithEmail,
                  label: 'Continue with Email',
                  icon: Icons.email_rounded,
                  color: AppTheme.primary,
                  textColor: Colors.white,
                ),
                if (!widget.isLinking) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _continueAsGuest,
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color color, textColor;
  final Color? borderColor;

  const _SocialButton(
      {required this.onPressed,
      required this.label,
      required this.icon,
      required this.color,
      required this.textColor,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          side: borderColor != null ? BorderSide(color: borderColor!) : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}
