import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/logger.dart';
import '../../../utils/remote_config.dart';

/// Ad orchestration for the 7-step Loan-Finder flow.
///
/// Sister to [LoanFinderProvider] (which owns the form state). Lives at the
/// shell-route level so each step's preload survives the navigation that
/// happens immediately after it. Pattern mirrors `OnboardingProvider`:
///   • [preloadAfterStep] kicks off the *next* step's native + *this* step's
///     outgoing interstitial.
///   • [next] awaits the interstitial → shows it → waits for dismiss →
///     navigates with the preloaded native handed off via `extra`.
///
/// All ad failures fall through to navigation — the user is never stuck.
class LoanFinderAdProvider extends ChangeNotifier {
  static const _interLoadTimeout = Duration(seconds: 6);
  static const _dismissTimeout = Duration(seconds: 30);

  /// Native ad to hand off to the next step. Owned here until [next]
  /// transfers it via `extra`.
  InlineAdManager? nextInline;

  /// Interstitial shown when leaving the current step.
  FullScreenAdManager? transitionInter;

  Completer<void>? _dismissCompleter;
  bool _busy = false;
  bool _disposed = false;
  int _preparedFor = -1;

  bool get busy => _busy;

  // ─── preload ────────────────────────────────────────────────────────────

  /// Call from the step screen's `initState`. Wipes any stale ads from a prior
  /// preload (e.g. the user back-navigated within the flow) and starts loading
  /// the ads needed *after* this step.
  ///
  /// [stepIndex] is 0-based — 0 = loanPurpose, 6 = loanUrgency.
  void preloadAfterStep(int stepIndex) {
    if (_preparedFor == stepIndex) return;
    _preparedFor = stepIndex;

    unawaited(nextInline?.dispose());
    unawaited(transitionInter?.dispose());
    nextInline = null;
    transitionInter = null;

    // Native for the next screen (step 7 / index 6 has none).
    final nextNative = _nativeFor(stepIndex + 1);
    if (nextNative.enabled && nextNative.adId.isNotEmpty) {
      nextInline = InlineAdManager(adData: nextNative);
      unawaited(nextInline!.load());
    }

    // Interstitial that fires when leaving this step.
    final outInter = _interFor(stepIndex);
    if (outInter.enabled && outInter.adId.isNotEmpty) {
      transitionInter = FullScreenAdManager(
        adData: outInter,
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
  }

  // ─── transition ─────────────────────────────────────────────────────────

  /// Shows the preloaded interstitial (if any) and navigates to [routeName].
  ///
  /// When [extra] is provided (e.g. step 7 → recommendations passes the
  /// [LoanFinderResult]), it overrides the inline-ad handoff and any
  /// preloaded [nextInline] is disposed locally.
  Future<void> next(
    BuildContext context,
    String routeName, {
    Object? extra,
  }) async {
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
      _navigate(context, routeName, extra);
    } catch (e, s) {
      '❌ loan-finder transition failed: $e'.logD;
      s.toString().logD;
      if (context.mounted) _navigate(context, routeName, extra);
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  void _navigate(BuildContext context, String routeName, Object? extra) {
    if (extra != null) {
      // Caller passed their own extra (e.g. a form result) — dispose the
      // unhanded-off native so it doesn't leak.
      unawaited(nextInline?.dispose());
      nextInline = null;
      context.pushNamed(routeName, extra: extra);
      return;
    }
    final handoff = nextInline;
    nextInline = null;
    context.pushNamed(routeName, extra: handoff);
  }

  // ─── slot lookup ────────────────────────────────────────────────────────

  /// Native for the screen at [stepIndex]. Returns a disabled [AdData] for
  /// out-of-range indices (e.g. stepIndex == 7 after the last step).
  static AdData _nativeFor(int stepIndex) {
    final rc = RemoteConfigService.instance;
    switch (stepIndex) {
      case 0:
        return rc.step1Native;
      case 1:
        return rc.step2Native;
      case 2:
        return rc.step3Native;
      case 3:
        return rc.step4Native;
      case 4:
        return rc.step5Native;
      case 5:
        return rc.step6Native;
      case 6:
        return rc.step7Native;
      default:
        return AdData.fromJson({});
    }
  }

  /// Interstitial fired *after* the screen at [stepIndex].
  static AdData _interFor(int stepIndex) {
    final rc = RemoteConfigService.instance;
    switch (stepIndex) {
      case 0:
        return rc.step1Inter;
      case 1:
        return rc.step2Inter;
      case 2:
        return rc.step3Inter;
      case 3:
        return rc.step4Inter;
      case 4:
        return rc.step5Inter;
      case 5:
        return rc.step6Inter;
      case 6:
        return rc.step7Inter;
      default:
        return AdData.fromJson({});
    }
  }

  /// Public accessor for the native of a given step — used by [LoanPurposeScreen]
  /// to load its own step-1 inline (no previous screen exists to hand one off).
  static AdData nativeForStep(int stepIndex) => _nativeFor(stepIndex);

  // ─── helpers ───────────────────────────────────────────────────────────

  void _completeDismiss() {
    final c = _dismissCompleter;
    if (c != null && !c.isCompleted) c.complete();
  }

  void _safeNotify() {
    if (!_disposed && hasListeners) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(nextInline?.dispose());
    unawaited(transitionInter?.dispose());
    super.dispose();
  }
}
