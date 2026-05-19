import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';
import '../utils/logger.dart';

/// to store local data
class AppDB {
  AppDB._(this._box);

  static const _appDbBox = '_appDbBox';
  final Box<dynamic> _box;

  /// to get instance
  static Future<AppDB> getInstance() async {
    try {
      final box = await Hive.openBox<dynamic>(_appDbBox);
      return AppDB._(box);
    } catch (e) {
      final appDir = await getApplicationDocumentsDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }
      final box = await Hive.openBox<dynamic>(_appDbBox);
      return AppDB._(box);
    }
  }

  /// save value
  T getValue<T>(String key, {T? defaultValue}) => _box.get(key, defaultValue: defaultValue) as T;

  /// save value
  Future<void> setValue<T>(String key, T value) => _box.put(key, value);

  /// to get user token
  String get token => getValue('token', defaultValue: '');

  ///to set user token
  set token(String update) => setValue('token', update);

  /// to get refresh token
  String get refreshToken => getValue('refreshToken', defaultValue: '');

  ///to set refresh token
  set refreshToken(String update) => setValue('refreshToken', update);

  ///Removes all user data except
  Future<void> logoutUser() async {
    try {
      await _box.clear();
    } catch (e) {
      e.logFatal;
    }
  }

  /// to set internet status
  set internetStatus(String status) => setValue('internetStatus', status);

  /// to get internet status
  String get internetStatus => getValue('internetStatus', defaultValue: 'connected');

  /// to check internet connection status is connected or not
  bool get isInternetConnected {
    return internetStatus == 'connected';
  }

  /// get language preference
  String get languageCode => getValue('languageCode', defaultValue: '');

  /// set language preference
  set languageCode(String update) => setValue('languageCode', update);

  /// --- Mining Session Management ---
  /// get selected country
  String get selectedCountry => getValue('selectedCountry', defaultValue: '');

  /// set selected country
  set selectedCountry(String update) => setValue('selectedCountry', update);

  /// to get user data
  UserModel? get userModel => getValue<Map<dynamic, dynamic>?>('userModel') != null
      ? UserModel.fromMap(Map<String, dynamic>.from(getValue('userModel')))
      : null;

  /// to set user data
  set userModel(UserModel? data) => setValue('userModel', data?.toMap());

  /// notifies user on value change
  Stream<BoxEvent> userListenable() {
    return _box.watch(key: 'userModel').asBroadcastStream();
  }

  bool get isOnBoardingComplete => getValue('isOnBoardingComplete', defaultValue: false);
  set isOnBoardingComplete(bool value) => setValue('isOnBoardingComplete', value);

  bool? get isOnboardingCompleted => getValue('isOnboardingCompleted');
  set isOnboardingCompleted(bool? value) => setValue('isOnboardingCompleted', value);

  String get currencyCode => getValue('currencyCode', defaultValue: 'USD');
  set currencyCode(String value) => setValue('currencyCode', value);

  String get currencySymbol => getValue('currencySymbol', defaultValue: r'$');
  set currencySymbol(String value) => setValue('currencySymbol', value);
}
