import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:finwise/db/app_db.dart';
import 'package:finwise/di/injector.dart';
import 'package:finwise/extension/ext_context.dart';
import 'package:finwise/gen/assets.gen.dart';
import 'package:finwise/routes/app_router.dart';
import 'package:finwise/utils/ad_repository.dart';
import 'package:finwise/utils/anaytics_manager.dart';
import 'package:finwise/utils/app_size.dart';
import 'package:finwise/utils/install_referrer_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finwise/utils/logger.dart';
import 'package:finwise/utils/remote_config.dart';
import 'package:finwise/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:play_install_referrer/play_install_referrer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Floor on splash duration so the animation has room to play even when ads
  /// resolve instantly (disabled / cached / failed).
  static const _minSplashDuration = Duration(milliseconds: 1800);

  /// Per-ad load timeout. After this, we stop waiting on `future()` and move on.
  static const _adLoadTimeout = Duration(seconds: 6);

  /// Wall-clock ceiling. No matter what happens (RC stalls, callback never
  /// fires, native code hangs), the user navigates away after this.
  static const _maxSplashDuration = Duration(seconds: 12);

  InlineAdManager? _banner;
  FullScreenAdManager? _fullScreen;

  /// Native ad for [Onboarding1Screen], preloaded here so the next screen
  /// renders an ad instead of an empty slot. Ownership is handed off via
  /// `extra` on navigation — this screen does NOT dispose it.
  InlineAdManager? _welcomeNative;

  Timer? _safetyTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _navigated = false;
  bool _showNoInternet = false;
  bool _retrying = false;
  bool _isShowingAd = false;
  DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'splash_screen');
    AdRepository.showConsentUMP();
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _connectivitySub?.cancel();
    unawaited(_banner?.dispose());
    unawaited(_fullScreen?.dispose());
    // Safety-dispose if we never handed off (e.g. screen torn down before nav).
    unawaited(_welcomeNative?.dispose());
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final hasNet = await _hasInternet();
    if (!mounted) return;

    if (!hasNet) {
      _watchForReconnect();
      setState(() => _showNoInternet = true);
      return;
    }
    _startAdFlow();
  }

  void _startAdFlow() {
    _startedAt = DateTime.now();
    _safetyTimer = Timer(_maxSplashDuration, () {
      '⚠️ splash safety timer fired — forcing navigate'.logD;
      unawaited(_goNext());
    });
    _initBanner();
    _preloadWelcomeNative();
    unawaited(_runFullScreenFlow());
  }

  /// Kicks off the load for [WelcomeScreen]'s native so it's ready (or in
  /// flight) by the time the user lands there. Handed off in [_goNext].
  ///
  /// Skipped when the user is going straight to home — loading and immediately
  /// discarding the native wastes bandwidth on every re-launch.
  void _preloadWelcomeNative() {
    if (_shouldGoHome()) return;
    final data = RemoteConfigService.instance.welcomeNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _welcomeNative = InlineAdManager(adData: data);
    unawaited(_welcomeNative!.load());
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      '⚠️ connectivity check failed: $e'.logD;
      // If the check itself fails, assume connected and let ad timeouts handle it.
      return true;
    }
  }

  /// Auto-retry the moment the user toggles wifi/mobile back on so they don't
  /// have to mash the Retry button.
  void _watchForReconnect() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final back = result.any((r) => r != ConnectivityResult.none);
      if (back && _showNoInternet && !_retrying) {
        unawaited(_onRetry());
      }
    });
  }

  Future<void> _onRetry() async {
    if (_retrying) return;
    setState(() => _retrying = true);

    final hasNet = await _hasInternet();
    if (!mounted) return;

    if (!hasNet) {
      setState(() => _retrying = false);
      return;
    }

    // Remote Config likely failed in main() if there was no internet —
    // refetch now that we're back online so ad slots populate.
    try {
      await RemoteConfigService.instance.init();
    } catch (e) {
      '⚠️ RC re-init failed: $e'.logD;
    }
    if (!mounted) return;

    _connectivitySub?.cancel();
    _connectivitySub = null;
    setState(() {
      _showNoInternet = false;
      _retrying = false;
    });
    _startAdFlow();
  }

  void _initBanner() {
    final data = RemoteConfigService.instance.splashBanner;
    if (!data.enabled || data.adId.isEmpty) return;

    _banner = InlineAdManager(adData: data);
    unawaited(_banner!.load());
    // BannerAd.load() resolves before fill — drive setState off future().
    unawaited(
      _banner!.future().then((_) {
        if (mounted) setState(() {});
      }),
    );
  }

  Future<void> _runFullScreenFlow() async {
    try {
      final data = RemoteConfigService.instance.splashAppOpen;

      // Remote Config says off (or wasn't fetched at all) — skip the ad.
      if (!data.enabled || data.adId.isEmpty) {
        await _waitForMinSplash();
        _goNext();
        return;
      }

      _fullScreen = FullScreenAdManager(
        adData: data,
        openAppCallback: FullScreenContentCallback<AppOpenAd>(
          onAdDismissedFullScreenContent: (_) {
            unawaited(_goNext());
          },
          onAdFailedToShowFullScreenContent: (_, _) {
            unawaited(_goNext());
          },
        ),
        interstitialCallback: FullScreenContentCallback<InterstitialAd>(
          onAdDismissedFullScreenContent: (_) {
            unawaited(_goNext());
          },
          onAdFailedToShowFullScreenContent: (_, _) {
            unawaited(_goNext());
          },
        ),
      );

      unawaited(_fullScreen!.load());
      final status = await _fullScreen!.future().timeout(
            _adLoadTimeout,
            onTimeout: () => AdStatus.failed,
          );

      // Always let the splash breathe a moment so the logo animation plays.
      await _waitForMinSplash();
      if (!mounted) return;

      if (status == AdStatus.loaded && (_fullScreen?.isLoaded ?? false)) {
        if (mounted) setState(() => _isShowingAd = true);
        final shown = await _fullScreen!.show();
        if (!shown) {
          unawaited(_goNext());
        }
        // shown == true → dismiss/fail callback drives navigation.
      } else {
        unawaited(_goNext());
      }
    } catch (e, s) {
      '❌ splash ad flow failed: $e'.logD;
      s.toString().logD;
      _goNext();
    }
  }

  Future<void> _waitForMinSplash() async {
    final elapsed = DateTime.now().difference(_startedAt);
    final remaining = _minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    _safetyTimer?.cancel();

    // Ensure the install-referrer fetch (kicked off in main()) is done before
    // we read the cached organic flag. Capped at 2s so we never block the user
    // on a stuck Play Services call — if it's not back by then, treat as
    // non-organic and let onboarding run.
    await InstallReferrerService.instance.resolveOnce().timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
    if (!mounted) return;

    await Permission.notification.request();
    if (!mounted) return;

    if (_shouldGoHome()) {
      // Home doesn't accept the onboarding native — dispose it locally so
      // it doesn't leak waiting for the splash's dispose().
      print('enter');
      unawaited(_welcomeNative?.dispose());
      _welcomeNative = null;
      context.goNamed(AppRoutes.home);
      return;
    }

    final handoff = _welcomeNative;
    _welcomeNative = null;
    context.goNamed(AppRoutes.welcome, extra: handoff);
    // Ownership of the preloaded native transfers to WelcomeScreen.

  }

  /// Routing decision after the splash flow:
  ///   • Organic install (Play `utm_medium=organic`) → check `show_onboarding_organic_install` RC flag
  ///     - If true → onboarding
  ///     - If false → home, skip onboarding
  ///   • `skip_onboarding` (RC)   → home (always, even on first launch).
  ///   • `show_multiple_onboarding` (RC) → onboarding (ignore prior completion).
  ///   • otherwise → home if the user has completed onboarding before, else onboarding.
  bool _shouldGoHome() {
    final db = Injector.instance<AppDB>();
    final rc = RemoteConfigService.instance;
    
    // Check if organic install
    if (db.isOrganicInstall) {
      // Use remote config to decide whether to show onboarding for organic installs
      if (!rc.showOnboardingOrganicInstall) {
        return true; // Skip onboarding for organic installs
      }
      // If showOnboardingOrganicInstall is true, continue to check other conditions
    }
    
    if (rc.skipOnBoarding) return true;
    if (rc.showMultipleOnboarding) return false;
    return db.isOnboardingCompleted ?? false;
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final logoSize = 310.w;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/splash_screen.png'),fit: BoxFit.fill)
        ),
        child: _showNoInternet
            ? _NoInternetView(
                onRetry: _onRetry,
                retrying: _retrying,
              )
            : _buildSplashContent(colors, logoSize),
      ),
    );
  }

  Widget _buildSplashContent(dynamic colors, double logoSize) {
    return Stack(
      children: [
        Positioned(
          bottom: AppSize.h180,
          right: 0,
          left: 0,
          child: Column(
            children: [
              Assets.images.splashScreenLogo
                  .image(
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.fill,
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.55, 0.55),
                    end: const Offset(1, 1),
                    duration: 900.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                  .blurXY(
                    begin: 14,
                    end: 0,
                    duration: 700.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .then(delay: 200.ms)
                  .shimmer(
                    duration: 1400.ms,
                    color: colors.whiteColor.withValues(alpha: 0.6),
                  ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: AlignmentGeometry.centerLeft,
                  end: AlignmentGeometry.centerRight,
                  colors: [
                    Color(0xff2563EB).withValues(alpha: 0.6),
                    Color(0xff153885).withValues(alpha: 0.7),
                  ],
                  stops: [0,1]
                ).createShader(bounds),
                child: Text('FinWise',style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.w32),)

              )
             ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isShowingAd)
                  SizedBox(
                    height: AppSize.h3,
                    child: LinearProgressIndicator(
                      minHeight: AppSize.h3,
                      backgroundColor:
                          colors.whiteColor.withValues(alpha: 0.25),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.whiteColor),
                    ),
                  ),
                if (_banner != null && _banner!.isLoaded)
                  SizedBox(
                    width: double.infinity,
                    child: _banner!.adWidget(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NoInternetView extends StatelessWidget {
  const _NoInternetView({required this.onRetry, required this.retrying});

  final VoidCallback onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.w24,
              vertical: AppSize.h28,
            ),
            decoration: BoxDecoration(
              color: colors.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.r24),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSize.w72,
                  height: AppSize.w72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.primary, colors.secondary],
                    ),
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: colors.whiteColor,
                    size: AppSize.sp36,
                  ),
                ),
                SizedBox(height: AppSize.h20),
                Text(
                  context.l10n.splashNoInternetTitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: textColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSize.sp18,
                  ),
                ),
                SizedBox(height: AppSize.h8),
                Text(
                  context.l10n.splashNoInternetDesc,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textColors.hintTextColor,
                    fontSize: AppSize.sp13,
                  ),
                ),
                SizedBox(height: AppSize.h24),
                AppButton(
                  text: retrying ? context.l10n.splashCheckingText : context.l10n.splashRetryText,
                  isLoading: retrying,
                  onPressed: onRetry,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 350.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
  }
}
