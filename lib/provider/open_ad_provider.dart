import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../routes/app_router.dart';
import '../utils/logger.dart';
import '../utils/remote_config.dart';
import '../widgets/loading_overlay/loading_overlay.dart';

/// Shows a full-screen ad (app-open / interstitial / custom — whatever Remote
/// Config points at) every time the app is resumed from background.
///
/// Routing is delegated to [FullScreenAdManager] so the slot can be flipped
/// between openApp, interstatial, and custom in Firebase without code changes.
class OpenAdProvider extends ChangeNotifier {
  OpenAdProvider();

  FullScreenAdManager? _openAdManager;
  AppLifecycleListener? _listener;

  void startOpenAdListener() {
    'open_ad listener start'.logD;
    ignoreNextEvent = true;
    _loadOpenAd();
    _startStateListener();
  }

  Future<void> _loadOpenAd() async {
    final data = RemoteConfigService.instance.appOpen;
    '[AD] app_open → id=${data.adId} type=${data.adType.name} enabled=${data.enabled}'.logD;

    _openAdManager?.dispose();
    _openAdManager = FullScreenAdManager(
      adData: data,
      openAppCallback: FullScreenContentCallback<AppOpenAd>(
        onAdWillDismissFullScreenContent: (_) => _loadOpenAd(),
        onAdFailedToShowFullScreenContent: (_, _) => _loadOpenAd(),
      ),
      interstitialCallback: FullScreenContentCallback<InterstitialAd>(
        onAdWillDismissFullScreenContent: (_) => _loadOpenAd(),
        onAdFailedToShowFullScreenContent: (_, _) => _loadOpenAd(),
      ),
    );
    await _openAdManager?.load();
  }

  Future<void> _startStateListener() async {
    _listener = AppLifecycleListener(
      onResume: () async {
        'open_ad on resume'.logD;
        if (!RemoteConfigService.instance.appOpen.enabled) return;
        if (ignoreNextEvent) {
          ignoreNextEvent = false;
          return;
        }

        final context = rootNavKey.currentContext;
        if (context == null || !context.mounted) return;

        final data = RemoteConfigService.instance.appOpen;
        final overlay = LoadingOverlay.instance()..show(context: context);

        try {
          if (data.adType == AdType.custom && data.enabled) {
            ignoreNextEvent = true;
            unawaited(launchUrlString(data.customAdUrl));
            await Future<void>.delayed(const Duration(milliseconds: 500));
            return;
          }

          final ad = _openAdManager;
          if (ad == null) return;
          await ad.future();
          if (ad.isLoaded) await ad.show();
        } finally {
          overlay.hide();
        }
      },
    );
  }

  @override
  void dispose() {
    _openAdManager?.dispose();
    _listener?.dispose();
    super.dispose();
  }
}
