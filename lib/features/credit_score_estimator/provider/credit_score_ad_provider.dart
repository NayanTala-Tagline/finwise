import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/logger.dart';
import '../../../utils/remote_config.dart';

/// Ad orchestration for the 6-step Credit Score Estimator flow.
///
/// Mirrors [LoanFinderAdProvider]:
///   • [preloadAfterStep] loads the next step's native + this step's outgoing
///     interstitial.
///   • [next] shows the interstitial → navigates, handing off the preloaded
///     native via [extra].
///
/// All ad failures fall through to navigation — the user is never stuck.
class CreditScoreAdProvider extends ChangeNotifier {
  static const _interLoadTimeout = Duration(seconds: 6);
  static const _dismissTimeout = Duration(seconds: 30);

  InlineAdManager? nextInline;
  FullScreenAdManager? transitionInter;

  Completer<void>? _dismissCompleter;
  bool _busy = false;
  bool _disposed = false;
  int _preparedFor = -1;

  bool get busy => _busy;

  // ─── preload ──────────────────────────────────────────────────────────────

  void preloadAfterStep(int stepIndex) {
    if (_preparedFor == stepIndex) return;
    _preparedFor = stepIndex;

    unawaited(nextInline?.dispose());
    unawaited(transitionInter?.dispose());
    nextInline = null;
    transitionInter = null;

    // Native for the next screen (step 6 / index 5 goes to result — no native).
    final nextNative = _nativeFor(stepIndex + 1);
    if (nextNative.enabled && nextNative.adId.isNotEmpty) {
      nextInline = InlineAdManager(adData: nextNative);
      unawaited(nextInline!.load());
    }

    // Interstitial fired when leaving this step.
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

  // ─── transition ───────────────────────────────────────────────────────────

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
      '❌ credit-score transition failed: $e'.logD;
      s.toString().logD;
      if (context.mounted) _navigate(context, routeName, extra);
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  void _navigate(BuildContext context, String routeName, Object? extra) {
    if (extra != null) {
      unawaited(nextInline?.dispose());
      nextInline = null;
      context.pushNamed(routeName, extra: extra);
      return;
    }
    final handoff = nextInline;
    nextInline = null;
    context.pushNamed(routeName, extra: handoff);
  }

  // ─── slot lookup ──────────────────────────────────────────────────────────

  static AdData _nativeFor(int stepIndex) {
    final rc = RemoteConfigService.instance;
    return switch (stepIndex) {
      0 => rc.creditCardStep1Native,
      1 => rc.creditCardStep2Native,
      2 => rc.creditCardStep3Native,
      3 => rc.creditCardStep4Native,
      4 => rc.creditCardStep5Native,
      5 => rc.creditCardStep6Native,
      _ => AdData.fromJson({}),
    };
  }

  static AdData _interFor(int stepIndex) {
    final rc = RemoteConfigService.instance;
    return switch (stepIndex) {
      0 => rc.creditCardStep1Inter,
      1 => rc.creditCardStep2Inter,
      2 => rc.creditCardStep3Inter,
      3 => rc.creditCardStep4Inter,
      4 => rc.creditCardStep5Inter,
      5 => rc.creditCardStep6Inter,
      _ => AdData.fromJson({}),
    };
  }

  static AdData nativeForStep(int stepIndex) => _nativeFor(stepIndex);

  // ─── helpers ──────────────────────────────────────────────────────────────

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
