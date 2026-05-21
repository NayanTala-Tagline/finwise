import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/logger.dart';
import '../../../utils/remote_config.dart';

/// Drives the onboarding step-to-step transitions:
///   1. preloads the *next* screen's native ad,
///   2. preloads the transition interstitial,
///   3. on Next: awaits the interstitial → shows it → waits for dismiss →
///      navigates with the preloaded native handed off via `extra`.
///
/// All ad failures (disabled, no fill, timeout, show failure) fall through to
/// navigation so the user is never stuck on a step.
class OnboardingProvider extends ChangeNotifier {
  /// Cap on how long we wait for the interstitial to finish loading before
  /// giving up and navigating.
  static const _interLoadTimeout = Duration(seconds: 6);

  /// Cap on how long we wait for the dismiss callback after `show()`.
  static const _dismissTimeout = Duration(seconds: 30);

  InlineAdManager? nextInline;
  FullScreenAdManager? transitionInter;
  Completer<void>? _dismissCompleter;
  bool _busy = false;
  bool _disposed = false;

  bool get busy => _busy;

  // ─── preload helpers ────────────────────────────────────────────────────

  void preloadOnboarding1Native() =>
      _preloadInline(RemoteConfigService.instance.onboardingNative1);

  void preloadOnboarding2Native() =>
      _preloadInline(RemoteConfigService.instance.onboardingNative2);

  void preloadOnboarding3Native() =>
      _preloadInline(RemoteConfigService.instance.onboardingNative3);

  void preloadOnboarding4Native() =>
      _preloadInline(RemoteConfigService.instance.onboardingNative4);

  void preloadOnboarding5Native() =>
      _preloadInline(RemoteConfigService.instance.onboardingNative5);

  void preloadInter1() =>
      _preloadInter(RemoteConfigService.instance.onboardingInter1);

  void preloadWelcomeInter() =>
      _preloadInter(RemoteConfigService.instance.welcomeInter);

  void preloadInter2() =>
      _preloadInter(RemoteConfigService.instance.onboardingInter2);

  void preloadInter3() =>
      _preloadInter(RemoteConfigService.instance.onboardingInter3);

  void preloadInter4() =>
      _preloadInter(RemoteConfigService.instance.onboardingInter4);

  void preloadInter5() =>
      _preloadInter(RemoteConfigService.instance.onboardingInter5);

  void _preloadInline(AdData data) {
    if (!data.enabled || data.adId.isEmpty) return;
    nextInline = InlineAdManager(adData: data);
    unawaited(nextInline!.load());
  }

  void _preloadInter(AdData data) {
    if (!data.enabled || data.adId.isEmpty) return;
    transitionInter = FullScreenAdManager(
      adData: data,
      interstitialCallback: FullScreenContentCallback<InterstitialAd>(
        onAdDismissedFullScreenContent: (_) => _completeDismiss(),
        onAdFailedToShowFullScreenContent: (_, _) => _completeDismiss(),
      ),
      openAppCallback: FullScreenContentCallback<AppOpenAd>(
        onAdDismissedFullScreenContent: (_) => _completeDismiss(),
        onAdFailedToShowFullScreenContent: (_, _) => _completeDismiss(),
      ),
    );
    unawaited(transitionInter!.load());
  }

  void _completeDismiss() {
    final c = _dismissCompleter;
    if (c != null && !c.isCompleted) c.complete();
  }

  // ─── public transitions ────────────────────────────────────────────────

  Future<void> nextTo1(BuildContext context) =>
      _transition(context, 'Onboarding1Screen');

  Future<void> skipToOnboarding1(BuildContext context) =>
      _transition(context, 'Onboarding1Screen');

  Future<void> nextTo2(BuildContext context) =>
      _transition(context, 'Onboarding2Screen');

  Future<void> nextTo3(BuildContext context) =>
      _transition(context, 'Onboarding3Screen');

  Future<void> nextTo4(BuildContext context) =>
      _transition(context, 'Onboarding4Screen');

  Future<void> nextTo5(BuildContext context) =>
      _transition(context, 'Onboarding5Screen');

  /// Final step. Caller is expected to have already set
  /// `AppDB.isOnboardingCompleted = true` (see [Onboarding5Screen]).
  Future<void> finishOnboarding(BuildContext context, String routeName) =>
      _transition(context, routeName);

  // ─── core transition flow ──────────────────────────────────────────────

  Future<void> _transition(BuildContext context, String routeName) async {
    if (_busy) return;
    _busy = true;
    _safeNotify();

    try {
      final inter = transitionInter;
      if (inter != null) {
        final status = await inter.future().timeout(
              _interLoadTimeout,
              onTimeout: () => AdStatus.failed,
            );
        if (status == AdStatus.loaded && inter.isLoaded) {
          _dismissCompleter = Completer<void>();
          final shown = await inter.show();
          if (shown) {
            await _dismissCompleter!.future.timeout(
              _dismissTimeout,
              onTimeout: () {},
            );
          }
          _dismissCompleter = null;
        }
      }

      if (!context.mounted) return;

      // Hand off ownership of the preloaded native to the next screen.
      final handoff = nextInline;
      nextInline = null;
      context.pushNamed(routeName, extra: handoff);
    } catch (e, s) {
      '❌ onboarding transition failed: $e'.logD;
      s.toString().logD;
      if (context.mounted) {
        final handoff = nextInline;
        nextInline = null;
        context.pushNamed(routeName, extra: handoff);
      }
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed && hasListeners) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(transitionInter?.dispose());
    // Safety-dispose if we never handed off (user backed out of the flow).
    unawaited(nextInline?.dispose());
    super.dispose();
  }
}
