import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/features/bottom_nav/ui/bottom_nav_page.dart';
import 'package:finwise/features/compare_module/compare_screen.dart';
import 'package:finwise/features/document_required/document_required_screen.dart';
import 'package:finwise/features/home_module/home_screen.dart';
import 'package:finwise/features/loan_finder/credit_score_screen.dart';
import 'package:finwise/features/loan_finder/employment_status_screen.dart';
import 'package:finwise/features/loan_finder/existing_loans_screen.dart';
import 'package:finwise/features/loan_finder/loan_amount_screen.dart';
import 'package:finwise/features/loan_finder/loan_purpose_screen.dart';
import 'package:finwise/features/loan_finder/loan_urgency_screen.dart';
import 'package:finwise/features/loan_finder/model/loan_finder_result.dart';
import 'package:finwise/features/loan_finder/monthly_income_screen.dart';
import 'package:finwise/features/loan_finder/provider/loan_finder_ad_provider.dart';
import 'package:finwise/features/loan_finder/provider/loan_finder_provider.dart';
import 'package:finwise/features/loan_finder/recommendations_screen.dart';
import 'package:finwise/features/onboarding/welcome_screen.dart';
import 'package:finwise/features/onboarding/onboarding1_screen.dart';
import 'package:finwise/features/onboarding/onboarding2_screen.dart';
import 'package:finwise/features/onboarding/onboarding3_screen.dart';
import 'package:finwise/features/onboarding/onboarding4_screen.dart';
import 'package:finwise/features/onboarding/onboarding5_screen.dart';
import 'package:finwise/features/loan_calculator/loan_calculator_screen.dart';
import 'package:finwise/features/loan_detail/loan_detail_screen.dart';
import 'package:finwise/features/loan_detail/model/loan_detail_data.dart';
import 'package:finwise/features/setting_module/setting_screen.dart';
import 'package:finwise/features/splash/splash_screen.dart';
import 'package:finwise/features/tips_advice/tips_advice_screen.dart';
import 'package:finwise/features/tools_module/tools_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../db/app_db.dart';
import '../di/injector.dart';

part 'bottom_nav_routes.dart';
part 'app_routes.dart';

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
    GoRoute(
      path: '/${AppRoutes.documentRequired}',
      name: AppRoutes.documentRequired,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const DocumentRequiredScreen(),
      ),
    ),
    GoRoute(
      path: '/${AppRoutes.tipsAdvice}',
      name: AppRoutes.tipsAdvice,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const TipsAdviceScreen(),
      ),
    ),
    // Loan-finder flow — shared LoanFinderProvider (form) +
    // LoanFinderAdProvider (ads) across all 7 steps.
    ShellRoute(
      builder: (context, state, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoanFinderProvider()),
          ChangeNotifierProvider(create: (_) => LoanFinderAdProvider()),
        ],
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/${AppRoutes.loanPurpose}',
          name: AppRoutes.loanPurpose,
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const LoanPurposeScreen()),
        ),
        GoRoute(
          path: '/${AppRoutes.loanAmount}',
          name: AppRoutes.loanAmount,
          pageBuilder: (context, state) {
            final ad = state.extra is InlineAdManager
                ? state.extra as InlineAdManager
                : null;
            return MaterialPage(
              key: state.pageKey,
              child: LoanAmountScreen(inlineAd: ad),
            );
          },
        ),
        GoRoute(
          path: '/${AppRoutes.monthlyIncome}',
          name: AppRoutes.monthlyIncome,
          pageBuilder: (context, state) {
            final ad = state.extra is InlineAdManager
                ? state.extra as InlineAdManager
                : null;
            return MaterialPage(
              key: state.pageKey,
              child: MonthlyIncomeScreen(inlineAd: ad),
            );
          },
        ),
        GoRoute(
          path: '/${AppRoutes.employmentStatus}',
          name: AppRoutes.employmentStatus,
          pageBuilder: (context, state) {
            final ad = state.extra is InlineAdManager
                ? state.extra as InlineAdManager
                : null;
            return MaterialPage(
              key: state.pageKey,
              child: EmploymentStatusScreen(inlineAd: ad),
            );
          },
        ),
        GoRoute(
          path: '/${AppRoutes.creditScore}',
          name: AppRoutes.creditScore,
          pageBuilder: (context, state) {
            final ad = state.extra is InlineAdManager
                ? state.extra as InlineAdManager
                : null;
            return MaterialPage(
              key: state.pageKey,
              child: CreditScoreScreen(inlineAd: ad),
            );
          },
        ),
        GoRoute(
          path: '/${AppRoutes.existingLoans}',
          name: AppRoutes.existingLoans,
          pageBuilder: (context, state) {
            final ad = state.extra is InlineAdManager
                ? state.extra as InlineAdManager
                : null;
            return MaterialPage(
              key: state.pageKey,
              child: ExistingLoansScreen(inlineAd: ad),
            );
          },
        ),
        GoRoute(
          path: '/${AppRoutes.loanUrgency}',
          name: AppRoutes.loanUrgency,
          pageBuilder: (context, state) {
            final ad = state.extra is InlineAdManager
                ? state.extra as InlineAdManager
                : null;
            return MaterialPage(
              key: state.pageKey,
              child: LoanUrgencyScreen(inlineAd: ad),
            );
          },
        ),
        // GoRoute(
        //   path: '/${AppRoutes.language}',
        //   name: AppRoutes.language,
        //   pageBuilder: (context, state) {
        //     return MaterialPage(key: state.pageKey, child:   LanguageScreen());
        //   },
        // ),
        // GoRoute(
        //   path: '/${AppRoutes.contactUs}',
        //   name: AppRoutes.contactUs,
        //   pageBuilder: (context, state) {
        //     return MaterialPage(key: state.pageKey, child:   ContactUsScreen());
        //   },
        // ),
      ],
    ),
    GoRoute(
      path: '/${AppRoutes.recommendations}',
      name: AppRoutes.recommendations,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: RecommendationsScreen(result: state.extra! as LoanFinderResult),
      ),
    ),
    GoRoute(
      path: '/${AppRoutes.loanDetail}',
      name: AppRoutes.loanDetail,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: LoanDetailScreen(loanType: state.extra! as LoanType),
      ),
    ),
    GoRoute(
      path: '/${AppRoutes.loanCalculator}',
      name: AppRoutes.loanCalculator,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const LoanCalculatorScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavPage(key: state.pageKey, child: navigationShell);
      },
      branches: _bottomNavBranches,
    ),
  ],
);
