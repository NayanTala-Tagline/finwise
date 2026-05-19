import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/utils/remote_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../routes/app_router.dart';
import '../widgets/ad_loading_overlay.dart';
import 'logger.dart';

/// Navigation gate that shows a full-screen ad every N taps.
///
/// Routing is delegated to [FullScreenAdManager] so Firebase Remote Config
/// can flip the `app_inter` slot between `interstatial`, `openApp`, and
/// `custom` (a browser URL redirect) without code changes.
class NavigationHelper {
  static final NavigationHelper _instance = NavigationHelper._internal();
  factory NavigationHelper() => _instance;
  NavigationHelper._internal();

  int _tapCount = 0;

  /// Read fresh on every tap so Remote Config updates take effect without
  /// rebuilding the singleton.
  int get _tapThreshold => RemoteConfigService.instance.appClickCounter;

  FullScreenAdManager? _fullScreenAd;

  /// True when the slot is configured to show any kind of ad.

  // ---------------------------------------------------------------------------
  // PUBLIC ENTRY POINTS
  // ---------------------------------------------------------------------------
  void handleBackPress(BuildContext context) {
    navigateWithAdCheck(context, () {
      context.pop();
    });
  }

  void addBackTap(BuildContext context) {
    navigateWithAdCheck(context, () {});
  }

  /// Main entry — increments the tap counter and shows an ad once the
  /// threshold is reached, otherwise navigates immediately.
  void navigateWithAdCheck(BuildContext context, VoidCallback onNavigate) {
    '/// taped...$_tapCount'.logV;

    // Slot is disabled → straight navigation.
    if (_fullScreenAd?.adData.enabled == false) {
      onNavigate();
      return;
    }

    _tapCount++;
    '/// tapCount: $_tapCount / $_tapThreshold'.logD;

    if (_tapCount >= _tapThreshold) {
      '/// go to load'.logD;
      _tapCount = 0;
      _handleAdSequence(context, onNavigate);
    } else {
      onNavigate();
    }
  }

  // ---------------------------------------------------------------------------
  // AD SEQUENCE
  // ---------------------------------------------------------------------------
  Future<void> _handleAdSequence(
      BuildContext context,
      VoidCallback onNavigate,
      ) async {
    final overlayContext =
    context.mounted ? context : rootNavKey.currentContext;
    if (overlayContext == null) {
      onNavigate();
      return;
    }

    final data = RemoteConfigService.instance.appInter;
    bool overlayShown = false;

    try {
      // Custom creative → launch URL in an in-app browser, wait briefly, then
      // run the app-level navigation behind it.
      if (data.adType == AdType.custom) {
        ignoreNextEvent = true;
        '/// launchURL'.logD;
        unawaited(
          launchUrlString(
            data.customAdUrl,
            mode: LaunchMode.inAppBrowserView,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 800));
        return;
      }

      // Real full-screen ad — FullScreenAdManager picks interstitial/openApp
      // based on adType. Callbacks are wired for both.
      if (data.enabled) {
        ignoreNextEvent = true;
        AdLoadingOverlay.show(overlayContext);
        overlayShown = true;

        _fullScreenAd?.dispose();
        _fullScreenAd = FullScreenAdManager(
          adData: data,
          interstitialCallback: FullScreenContentCallback<InterstitialAd>(
            onAdShowedFullScreenContent: (_) => 'Ad Shown'.logI,
            onAdDismissedFullScreenContent: (_) => 'Ad Dismissed'.logI,
            onAdFailedToShowFullScreenContent: (_, _) => 'Ad Failed Show'.logI,
          ),
          openAppCallback: FullScreenContentCallback<AppOpenAd>(
            onAdShowedFullScreenContent: (_) => 'Ad Shown'.logI,
            onAdDismissedFullScreenContent: (_) => 'Ad Dismissed'.logI,
            onAdFailedToShowFullScreenContent: (_, _) => 'Ad Failed Show'.logI,
          ),
        );

        await _fullScreenAd!.load();
        await _fullScreenAd!.future();
        if (_fullScreenAd!.isLoaded) {
          await _fullScreenAd!.show();
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('Ad Logic Exception: $e');
    } finally {
      if (overlayShown) AdLoadingOverlay.hide();
      // Runs after ad dismiss / URL launch.
      onNavigate();
    }
  }

  /// Call this to reset counter if needed.
  void resetCounter() {
    _tapCount = 0;
  }
}
