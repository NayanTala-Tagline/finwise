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

  /// get user information
  // SignUpAndSignInModel? get userModel => getValue<dynamic>('userModel') != null
  //     ? SignUpAndSignInModel.fromJson(
  //         Map<String, dynamic>.from(getValue('userModel')),
  //       )
  //     : null;

  bool get isMiningActive => getValue('isMiningActive', defaultValue: false);
  set isMiningActive(bool value) => setValue('isMiningActive', value);

  DateTime? get miningStartTime {
    final millis = getValue<int?>('miningStartTime');
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true) : null;
  }

  set miningStartTime(DateTime? value) => setValue('miningStartTime', value?.millisecondsSinceEpoch);

  /*
  double get totalMined => getValue('totalMined', defaultValue: 0.0);
  set totalMined(double value) => setValue('totalMined', value);
*/

  bool get isSpeedBoosterUsed => getValue('isSpeedBoosterUsed', defaultValue: false);
  set isSpeedBoosterUsed(bool value) => setValue('isSpeedBoosterUsed', value);

  bool get isTimeBoosterUsed => getValue('isTimeBoosterUsed', defaultValue: false);
  set isTimeBoosterUsed(bool value) => setValue('isTimeBoosterUsed', value);

  DateTime? get boostEndTime {
    final millis = getValue<int?>('boostEndTime');
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true) : null;
  }

  set boostEndTime(DateTime? value) => setValue('boostEndTime', value?.millisecondsSinceEpoch);

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

  double? get pendingSyncValue => getValue('pendingSyncValue');
  set pendingSyncValue(double? value) => setValue('pendingSyncValue', value);

  bool get isOnBoardingComplete => getValue('isOnBoardingComplete', defaultValue: false);
  set isOnBoardingComplete(bool value) => setValue('isOnBoardingComplete', value);

  Map<String, String>? get selectedNodeInfo {
    final map = getValue<Map<dynamic, dynamic>?>('selectedNodeInfo');
    // Ensure map is correctly cast to the expected type
    return map != null ? Map<String, String>.from(map) : null;
  }

  /// set selected node information
  set selectedNodeInfo(Map<String, String>? update) => setValue('selectedNodeInfo', update);

  // -------------------------
  // BOOSTER LOCAL STORAGE
  // -------------------------
  /// ✅ Save last-used time of a booster
  void setBoosterLastUsed(double bonusSpeed, DateTime? value) {
    setValue('booster_${bonusSpeed}_lastUsed', value?.millisecondsSinceEpoch);
  }

  /// ✅ Retrieve last-used time (for cooldown logic)
  DateTime? getBoosterLastUsed(double bonusSpeed) {
    final millis = getValue<int?>('booster_${bonusSpeed}_lastUsed');
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true) : null;
  }

  /// ✅ Save end time of active booster (when user activates it)
  void setBoosterEndTime(double bonusSpeed, DateTime? value) {
    setValue('booster_${bonusSpeed}_endTime', value?.millisecondsSinceEpoch);
  }

  /// ✅ Retrieve end time to resume booster after restart
  DateTime? getBoosterEndTime(double bonusSpeed) {
    final millis = getValue<int?>('booster_${bonusSpeed}_endTime');
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true) : null;
  }

  bool? get isOnboardingCompleted => getValue('isOnboardingCompleted');
  set isOnboardingCompleted(bool? value) => setValue('isOnboardingCompleted', value);

  String get currencyCode => getValue('currencyCode', defaultValue: 'USD');
  set currencyCode(String value) => setValue('currencyCode', value);

  /// True once the Play install referrer has been fetched (success OR failure).
  /// Prevents repeated API calls — the referrer never changes for an install.
  bool get installReferrerChecked => getValue('installReferrerChecked', defaultValue: false);
  set installReferrerChecked(bool value) => setValue('installReferrerChecked', value);

  /// Raw referrer string returned by Play (e.g. `utm_source=test&utm_medium=cpc`).
  /// Empty when the fetch failed or the platform is not Android.
  String get installReferrerRaw => getValue('installReferrerRaw', defaultValue: '');
  set installReferrerRaw(String value) => setValue('installReferrerRaw', value);

  /// True when utm_medium parsed from the referrer is `organic`.
  /// Organic installs skip onboarding and land on home directly.
  bool get isOrganicInstall => getValue('isOrganicInstall', defaultValue: false);
  set isOrganicInstall(bool value) => setValue('isOrganicInstall', value);

  String get currencySymbol => getValue('currencySymbol', defaultValue: r'$');
  set currencySymbol(String value) => setValue('currencySymbol', value);

  // -------------------------
  // NEW BOOSTER STORAGE (ADS & ACTIVE FLAGS)
  // -------------------------

  // Node Efficiency
  int get nodeEfficiencyAdsWatched => getValue('nodeEfficiencyAdsWatched', defaultValue: 0);
  set nodeEfficiencyAdsWatched(int value) => setValue('nodeEfficiencyAdsWatched', value);

  bool get isNodeEfficiencyApplied => getValue('isNodeEfficiencyApplied', defaultValue: false);
  set isNodeEfficiencyApplied(bool value) => setValue('isNodeEfficiencyApplied', value);

  // Session Duration
  int get sessionDurationAdsWatched => getValue('sessionDurationAdsWatched', defaultValue: 0);
  set sessionDurationAdsWatched(int value) => setValue('sessionDurationAdsWatched', value);

  bool get isSessionDurationApplied => getValue('isSessionDurationApplied', defaultValue: false);
  set isSessionDurationApplied(bool value) => setValue('isSessionDurationApplied', value);

  // Combined Session
  int get combinedSessionAdsWatched => getValue('combinedSessionAdsWatched', defaultValue: 0);
  set combinedSessionAdsWatched(int value) => setValue('combinedSessionAdsWatched', value);

  bool get isCombinedSessionApplied => getValue('isCombinedSessionApplied', defaultValue: false);
  set isCombinedSessionApplied(bool value) => setValue('isCombinedSessionApplied', value);

  // Current Session Duration (to persist extended time)
  int get currentSessionDuration => getValue('currentSessionDuration', defaultValue: 1800);
  set currentSessionDuration(int value) => setValue('currentSessionDuration', value);

  // Current Session Speed (to persist boosted speed)
  double get currentSessionSpeed => getValue('currentSessionSpeed', defaultValue: 0.95);
  set currentSessionSpeed(double value) => setValue('currentSessionSpeed', value);

  /// Clear all mining-related data (after sync)
  Future<void> clearMiningData() async {
    await _box.delete('isMiningActive');
    await _box.delete('miningStartTime');
    await _box.delete('boostEndTime');
    await _box.delete('pendingSyncValue');
    await _box.delete('booster_7.6_lastUsed');
    await _box.delete('booster_7.6_endTime');
    await _box.delete('booster_15.2_lastUsed');
    await _box.delete('booster_15.2_endTime');

    // Clear new booster data
    await _box.delete('nodeEfficiencyAdsWatched');
    await _box.delete('isNodeEfficiencyApplied');
    await _box.delete('sessionDurationAdsWatched');
    await _box.delete('isSessionDurationApplied');
    await _box.delete('combinedSessionAdsWatched');
    await _box.delete('isCombinedSessionApplied');
    await _box.delete('currentSessionDuration');
    await _box.delete('currentSessionSpeed');
  }
}
