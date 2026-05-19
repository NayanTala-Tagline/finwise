import 'package:ad_manager/ad_manager.dart';
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
          MaterialPage(key: state.pageKey, child: const Scaffold()),
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
