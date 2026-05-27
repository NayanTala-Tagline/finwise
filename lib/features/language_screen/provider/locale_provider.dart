import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../../../db/app_db.dart';
import '../../../../di/injector.dart';
import '../../../../utils/logger.dart';

bool hasInternet = true;

class LocaleProvider with ChangeNotifier {
  static const String _languageCodeKey = 'languageCode';
  static const String _countryCodeKey = 'countryCode';

  Locale? _locale;
  bool isValueChanged = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('fr'),
    Locale('sw'),
    Locale('ar'),
    Locale('hi'),
    Locale('ms'),
    Locale('fil'),
    Locale('es'),
    Locale('nl'),
  ];

  /// Optional: for UI selection
  int selectedIndex = 0;

  LocaleProvider() {
    initLocale(); // ✅ IMPORTANT: auto load saved language
    _startInternetListener();
  }

  Locale? get locale => _locale;
  bool isSelected = false;

  /// Load saved locale from local DB
  Future<void> initLocale() async {
    final db = Injector.instance<AppDB>();

    final langCode = db.getValue<String?>('languageCode');
    final countryCode = db.getValue<String?>('countryCode');

    if (langCode != null && langCode.isNotEmpty) {
      _locale = countryCode != null && countryCode.isNotEmpty
          ? Locale(langCode, countryCode)
          : Locale(langCode);

      // ✅ restore selected index
      selectedIndex = supportedLocales.indexWhere(
            (loc) => loc.languageCode == langCode,
      );

      isSelected = true;
    }

    notifyListeners();
  }

  /// Change locale + save locally
  Future<void> setLocale(Locale newLocale, int index, bool selected) async {
    if (!_isSupportedLocale(newLocale)) return;

    final db = Injector.instance<AppDB>();

    _locale = newLocale;

    // ✅ SAVE TO LOCAL
    await db.setValue('languageCode', newLocale.languageCode);
    await db.setValue('countryCode', newLocale.countryCode ?? '');

    isValueChanged = true;
    isSelected = selected;
    selectedIndex = index;

    notifyListeners();
  }

  /// Check supported locale
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.any(
          (supported) => supported.languageCode == locale.languageCode,
    );
  }

  /// Get current language code
  String? getCurrentLocaleCode() => _locale?.languageCode;

  /// Internet listener
  void _startInternetListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
          hasInternet = !result.contains(ConnectivityResult.none);

          'hasInternet $hasInternet'.logD;

          Injector.instance<AppDB>().internetStatus =
          hasInternet ? 'connected' : 'disconnected';
        });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}