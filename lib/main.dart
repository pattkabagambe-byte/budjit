import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/navigation/app_shell.dart';
import 'core/providers/core_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;
  var firebaseReady = false;

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (error) {
    startupError = error;
  }

  try {
    await MobileAds.instance.initialize();
  } catch (_) {}

  const purchasesApiKey = 'REVENUECAT_BUDJIT_KEY';
  if (!purchasesApiKey.startsWith('REVENUECAT_')) {
    try {
      await Purchases.configure(PurchasesConfiguration(purchasesApiKey));
    } catch (_) {}
  }

  // Load saved currency preference
  String savedCurrency = 'UGX';
  try {
    final prefs = await SharedPreferences.getInstance();
    savedCurrency = prefs.getString('currency') ?? 'UGX';
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        currencyProvider.overrideWith((ref) => savedCurrency),
      ],
      child: BudjitApp(firebaseReady: firebaseReady, startupError: startupError),
    ),
  );
}

class BudjitApp extends StatelessWidget {
  const BudjitApp({super.key, required this.firebaseReady, this.startupError});

  final bool firebaseReady;
  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budjit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: _Root(firebaseReady: firebaseReady, startupError: startupError),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root({required this.firebaseReady, this.startupError});

  final bool firebaseReady;
  final Object? startupError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!firebaseReady) return _StartupError(startupError: startupError);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }

        // Not signed in — show auth
        if (snapshot.data == null) return const AuthScreen();

        // Signed in — check onboarding
        return const _OnboardingGate();
      },
    );
  }
}

class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(onboardingCompleteProvider);

    return onboardingAsync.when(
      loading: () => const _Splash(),
      error: (_, __) => const AppShell(),
      data: (complete) => complete ? const AppShell() : const OnboardingScreen(),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060F1E) : Colors.white,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Budjit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text('Startup failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                startupError?.toString() ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
