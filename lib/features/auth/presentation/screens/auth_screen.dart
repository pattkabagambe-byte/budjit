import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/theme/app_theme.dart';

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

  Future<void> _applyCredential(AuthCredential credential) async {
    final auth = FirebaseAuth.instance;
    if (widget.isLinking && auth.currentUser != null) {
      await auth.currentUser!.linkWithCredential(credential);
      if (mounted) Navigator.of(context).pop();
    } else {
      await auth.signInWithCredential(credential);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      final gUser = await GoogleSignIn().signIn();
      if (gUser == null) { setState(() => _loading = false); return; }
      final gAuth = await gUser.authentication;
      await _applyCredential(GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      ));
    } catch (e) {
      setState(() { _error = 'Sign in failed. Please try again.'; _loading = false; });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() { _loading = true; _error = null; });
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      await _applyCredential(OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      ));
    } catch (e) {
      setState(() { _error = 'Apple sign in failed.'; _loading = false; });
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      setState(() { _error = 'Could not start guest session.'; _loading = false; });
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
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setDialogState(() => isRegister = !isRegister),
                child: Text(isRegister ? 'Already have an account? Sign in' : 'No account? Create one'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (isRegister) {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text);
                  } else {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
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
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome',
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isLinking
                    ? 'Sign in to sync your data across all devices.'
                    : 'Track your budget. Sign in to sync, or continue as guest.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
              ),
              const Spacer(),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: TextStyle(color: Colors.red.shade800)),
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
                      style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
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

  const _SocialButton({required this.onPressed, required this.label, required this.icon, required this.color, required this.textColor, this.borderColor});

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}
