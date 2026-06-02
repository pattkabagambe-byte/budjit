import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'ad_manager.dart';

/// Listens for foreground transitions and premium status to drive app open ads.
class AdLifecycleHandler extends ConsumerStatefulWidget {
  const AdLifecycleHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdLifecycleHandler> createState() => _AdLifecycleHandlerState();
}

class _AdLifecycleHandlerState extends ConsumerState<AdLifecycleHandler>
    with WidgetsBindingObserver {
  AppLifecycleState? _lastState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final previous = _lastState;
    _lastState = state;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        AdManager.instance.onAppBackgrounded();
      case AppLifecycleState.resumed:
        // Only react to a real return from background, not every resumed tick.
        if (previous == AppLifecycleState.paused ||
            previous == AppLifecycleState.inactive ||
            previous == AppLifecycleState.hidden) {
          AdManager.instance.onAppForegrounded();
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isPremiumProvider, (previous, next) {
      AdManager.instance.setAdsDisabled(next);
    });

    return widget.child;
  }
}
