import 'dart:io';

import 'package:share_plus/share_plus.dart';

/// Share Budjit with friends — no personal contact details in the message.
abstract final class AppShareService {
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=app.budjit.budjit';
  static const String _webUrl = 'https://budjit.app';

  static Future<void> shareApp() async {
    final storeLine = Platform.isIOS
        ? 'Download on the App Store or visit $_webUrl'
        : 'Get it on Google Play: $_playStoreUrl';

    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out Budjit — your personal budget planner and tracker.\n\n'
            '$storeLine',
        subject: 'Try Budjit',
      ),
    );
  }
}
