import 'package:flutter/material.dart';

import '../review/review_service.dart';

/// Records sessions and may show a periodic in-app rating prompt.
class AppEngagementScope extends StatefulWidget {
  const AppEngagementScope({super.key, required this.child});

  final Widget child;

  @override
  State<AppEngagementScope> createState() => _AppEngagementScopeState();
}

class _AppEngagementScopeState extends State<AppEngagementScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onReady());
  }

  Future<void> _onReady() async {
    await ReviewService.instance.recordSessionOpen();
    if (!mounted) return;
    await ReviewService.instance.maybeShowRatingPrompt(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
