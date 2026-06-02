# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

FinWise is a Flutter (Dart SDK ^3.11.1) financial-tools/loan app for Android & iOS. Application ID: `com.finwise.finance.calc.loanchecker`. It is ad-monetized (AdMob + mediation), Firebase-backed, and remote-config driven.

## Commands

```bash
flutter pub get                       # install deps (also resolves the local ad_manager package)
flutter run                           # run on connected device/emulator
flutter analyze                       # lint (flutter_lints, configured in analysis_options.yaml)
flutter test                          # run all tests
flutter test test/widget_test.dart    # run a single test file
flutter build apk --release           # Android release build
flutter build ios --release           # iOS release build
```

Code generation (run after editing assets, fonts, or localization `.arb` files):

```bash
dart run build_runner build --delete-conflicting-outputs   # regenerates lib/gen/ (flutter_gen)
flutter gen-l10n                                            # regenerates lib/l10n/app_localizations.dart from lib/l10n/*.arb
flutter pub run flutter_native_splash:create               # regenerate native splash from pubspec config
```

Generated files (`lib/gen/assets.gen.dart`, `lib/gen/fonts.gen.dart`, `lib/l10n/app_localizations.dart`) are committed — regenerate rather than hand-editing.

## Architecture

### Two-package layout
- Root app `finwise` (`lib/`).
- Local path package `ad_manager` (`ad_manager/`) — a self-contained ads SDK wrapping `google_mobile_ads` plus mediation adapters (Unity, AppLovin, Meta). It is depended on via `path:` in `pubspec.yaml` and re-exports `google_mobile_ads` from `package:ad_manager/ad_manager.dart`. Each ad format has its own manager (`banner_`, `interstitial_`, `native_`, `rewarded_`, `open_app_`, `inline_`); `FullScreenAdManager` dispatches to interstitial/openApp/rewarded based on `AdData.adType`.

### Startup flow (`lib/main.dart`)
`main()` is the central init point and order matters: Firebase → Crashlytics error hooks (`FlutterError.onError`, `PlatformDispatcher.instance.onError`) → Hive → `Injector.initModules()` → wait for `AppDB` ready → GoogleSignIn → **RemoteConfig** → MobileAds → Meta SDK → install-referrer (fire-and-forget). The app is locked to portrait. Root widget wraps everything in `ScreenUtilInit` (design size 375×812) and `MaterialApp.router`.

### Dependency injection — `lib/di/`
GetIt via the `Injector` facade (`Injector.instance`). Services are registered in `ServicesInjector._init()` (`inject_services.dart`). `AppDB` is an async singleton — `await Injector.instance.isReady<AppDB>()` before using it. Add new services in `inject_services.dart`, not ad-hoc.

### Local persistence — `lib/db/app_db.dart`
`AppDB` is a single Hive box (`_appDbBox`) exposed through typed getter/setter pairs (token, languageCode, currencyCode/currencySymbol, onboarding flags, install-referrer state, etc.). Add new persisted values as getter/setter pairs here rather than opening boxes elsewhere. `getInstance()` self-heals a corrupt box by deleting the app documents dir and reopening.

### Remote config drives behavior — `lib/utils/remote_config.dart`
`RemoteConfigService.instance` fetches a single JSON string under the `android` Firebase Remote Config key and parses it into ad/feature config. Ad placements come from this config as `AdData` objects (`ad_id`, `enabled`, `ad_type`, `template_type`, `height`, custom-ad URLs). Treat remote config as the source of truth for which ads are enabled and how they render; missing/invalid keys fall back to disabled empty ads. `lib/utils/ad_repository.dart` and `reward_ad_helper.dart` bridge remote-config `AdData` into the `ad_manager` managers.

### Routing — `lib/routes/`
`go_router` with a single `appRouter` (`app_router.dart`), split across `part` files `app_routes.dart` (route-name constants in `AppRoutes`) and `bottom_nav_routes.dart` (the `StatefulShellRoute` bottom-nav: home / tools / compare / settings). Navigate by **name** using `AppRoutes` constants. `rootNavKey` and `sfMessengerKey` are global keys; initial redirect depends on `AppDB.isOnboardingCompleted` + `FirebaseAuth.currentUser` + organic-install flag.

### Feature modules — `lib/features/<feature>/`
Each feature is self-contained: top-level `*_screen.dart` files plus optional `provider/`, `model/`, and `widgets/` subfolders. State management is **`provider` / `ChangeNotifier`** (not GetIt) for UI state — `LocaleProvider` and `CurrencyProvider` are app-global (registered in the root `MultiProvider`); per-feature providers (e.g. `LoanFinderProvider`, `CreditScoreEstimatorProvider`) are scoped within their route. Many features pair a domain provider with an `*_ad_provider.dart` that manages ads for that flow. Follow this folder convention when adding a feature.

### Shared code
- `lib/extension/` — extension methods on core types; **logging is done via these**: `'msg'.logD / .logE / .logW` etc. (`lib/utils/logger.dart`, `LoggerEx`). Use these instead of `print`.
- `lib/res/` — theming (`lightTheme`/`darkTheme`, color & text-color palettes). App currently forces `ThemeMode.light`.
- `lib/utils/` — cross-cutting services: `AnalyticsManager` (Firebase + Meta SDK), `CrashlyticsManager`, `InstallReferrerService` (Play install referrer → organic detection), `NumberFormatter`, navigation helpers.
- `lib/l10n/` — localization; edit `.arb` files (template `app_en.arb`), then regenerate. `untranslated_fields.txt` lists missing translations.

## Conventions
- Reference assets/fonts through generated `lib/gen/` classes (`Assets`, `FontFamily`), not raw string paths.
- Sizing uses `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`) against the 375×812 design.
- Logging uses the `LoggerEx` extension getters, not `print`/`debugPrint`.
- `native_ads_android_setup.md` documents the native-ad Android wiring; consult it before changing native-ad platform code.
