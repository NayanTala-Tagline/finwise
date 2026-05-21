import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/features/onboarding/welcome_screen.dart';
import 'package:finwise/features/onboarding/onboarding1_screen.dart';
import 'package:finwise/features/onboarding/onboarding2_screen.dart';
import 'package:finwise/features/onboarding/onboarding3_screen.dart';
import 'package:finwise/features/onboarding/onboarding4_screen.dart';
import 'package:finwise/features/onboarding/onboarding5_screen.dart';
import 'package:finwise/features/splash/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../db/app_db.dart';
import '../di/injector.dart';

part 'app_routes.dart';
part 'bottom_nav_routes.dart';

/// bottom navigation routes

/// root navigation key
final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Scaffold navigation key
final GlobalKey<ScaffoldMessengerState> sfMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'appScaffold');

final AppDB _db = Injector.instance<AppDB>();
final FirebaseAuth _auth = FirebaseAuth.instance;
bool isNavigateAuth =
    _db.isOnboardingCompleted == true && _auth.currentUser == null;
bool isNavigateStart =
    _db.isOnboardingCompleted == true && _auth.currentUser != null;

/// current route
String? currentRoute;

/// global GoRouter instance which has all page routes
final appRouter = GoRouter(
  navigatorKey: rootNavKey,
  debugLogDiagnostics: kDebugMode,
  //  observers: [AdNavigationObserver()],
  redirect: (context, state) {
    switch (state.fullPath) {
      case '/':
        return '/${AppRoutes.splash}';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const Scaffold(body: Center(child: Text('Home Screen'),),)),
    ),
    GoRoute(
      path: '/${AppRoutes.splash}',
      name: AppRoutes.splash,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SplashScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.welcome}',
      name: AppRoutes.welcome,
      pageBuilder: (context, state) {
        final ad = state.extra is InlineAdManager
            ? state.extra as InlineAdManager
            : null;
        return MaterialPage(
          key: state.pageKey,
          child: WelcomeScreen(inlineAd: ad),
        );
      },
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding1}',
      name: AppRoutes.onboarding1,
      pageBuilder: (context, state) {
        final ad = state.extra is InlineAdManager
            ? state.extra as InlineAdManager
            : null;
        return MaterialPage(
          key: state.pageKey,
          child: Onboarding1Screen(inlineAd: ad),
        );
      },
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding2}',
      name: AppRoutes.onboarding2,
      pageBuilder: (context, state) {
        final ad = state.extra is InlineAdManager
            ? state.extra as InlineAdManager
            : null;
        return MaterialPage(
          key: state.pageKey,
          child: Onboarding2Screen(inlineAd: ad),
        );
      },
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding3}',
      name: AppRoutes.onboarding3,
      pageBuilder: (context, state) {
        final ad = state.extra is InlineAdManager
            ? state.extra as InlineAdManager
            : null;
        return MaterialPage(
          key: state.pageKey,
          child: Onboarding3Screen(inlineAd: ad),
        );
      },
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding4}',
      name: AppRoutes.onboarding4,
      pageBuilder: (context, state) {
        final ad = state.extra is InlineAdManager
            ? state.extra as InlineAdManager
            : null;
        return MaterialPage(
          key: state.pageKey,
          child: Onboarding4Screen(inlineAd: ad),
        );
      },
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding5}',
      name: AppRoutes.onboarding5,
      pageBuilder: (context, state) {
        final ad = state.extra is InlineAdManager
            ? state.extra as InlineAdManager
            : null;
        return MaterialPage(
          key: state.pageKey,
          child: Onboarding5Screen(inlineAd: ad),
        );
      },
    ),

    // Loan-finder flow — shared LoanFinderProvider (form) +
    // LoanFinderAdProvider (ads) across all 7 steps.

    // StatefulShellRoute.indexedStack(
    //   builder: (context, state, navigationShell) {
    //     return BottomNavPage(key: state.pageKey, child: navigationShell);
    //   },
    //   branches: _bottomNavBranches,
    // ),
  ],
);
