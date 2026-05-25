import 'dart:async';
import 'dart:ui';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/features/currency_screen/provider/currency_provider.dart';
import 'package:finwise/firebase_option.dart';
import 'package:finwise/utils/install_referrer_service.dart';
import 'package:finwise/utils/remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'db/app_db.dart';
import 'di/injector.dart';
import 'l10n/app_localizations.dart';
import 'res/theme_dark.dart';
import 'res/theme_light.dart';
import 'routes/app_router.dart';
import 'utils/crashlytics_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (FlutterErrorDetails details) {
    CrashlyticsManager.instance.logFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    CrashlyticsManager.instance.logHandledDartError(error: error, stackTrace: stack);
    return true;
  };
  await Hive.initFlutter();
  Injector.initModules();

  // assetToFilePath(Assets.images.onBoarding2.path);
  await Injector.instance.isReady<AppDB>();
  await GoogleSignIn.instance.initialize();
  await RemoteConfigService.instance.init();
  await MobileAds.instance.initialize();
  unawaited(InstallReferrerService.instance.resolveOnce());

  // 🔒 Lock orientation (portrait only)
  // _iZootoInitialise();
  // await NotificationHelper.initializeNotification();
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // OneSignal.initialize("0f5903ef-d2b4-4091-91c8-c7d42bb53dfe");
  // OneSignal.Notifications.requestPermission(false);
  // await AnalyticsManager.instance.initMetaSdk();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
      MultiProvider(
        providers: [
          // ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ],
        child:
        MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Figma page size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // return Consumer<LocaleProvider>(
        //     builder: (context,localeProvider,_) {
              return MaterialApp.router(
                title: 'FinWise',
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                // locale: localeProvider.locale ?? const Locale('en'),
                themeMode: ThemeMode.light,
                theme: lightTheme,
                darkTheme: darkTheme,
                routerConfig: appRouter,
              );
            // }
        // );
      },
    );
  }
}