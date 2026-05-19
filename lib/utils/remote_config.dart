import 'dart:convert';
import 'package:ad_manager/models/ad_data.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'logger.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  static RemoteConfigService get instance => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  Map<String, dynamic> _appData = {};
  Map<String, dynamic> _btcCloudManager = {};

  RemoteConfigService._internal();

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------
  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      '⚠️ Remote config fetch failed: $e'.logD;
      return;
    }

    final jsonString = _remoteConfig.getString('android');
    // final jsonString1 = _remoteConfig.getString('btc_cloud_manager');

    if (jsonString.isEmpty) {
      '⚠️ android key is empty in Remote Config'.logD;
      return;
    }

    try {
      _appData = jsonDecode(jsonString) as Map<String, dynamic>;
      // _btcCloudManager = jsonDecode(jsonString1) as Map<String, dynamic>;
      '✅ Remote config loaded successfully'.logD;
    } catch (e) {
      _appData = {};
      _btcCloudManager = {};
      '❌ Failed to decode remote config JSON: $e'.logD;
    }
  }

  // ---------------------------------------------------------------------------
  // INTERNAL HELPERS
  // ---------------------------------------------------------------------------

  AdData _getAdData(String key) {
    try {
      final raw = _appData[key];

      if (raw == null || raw is! Map<String, dynamic>) {
        '⚠️ $key missing or invalid'.logD;
        return AdData.fromJson(_emptyAd());
      }

      final Map<String, dynamic> data = {
        'ad_id': raw['ad_id'] ?? '',
        'enabled': raw['enabled'] ?? false,

        // ✅ NEW FIELD
        'ad_type': raw['ad_type'] ?? 'native',

        // ✅ TEMPLATE TYPE
        'template_type': raw['template_type'] ?? 'small',

        // 🔥 SAFE DOUBLE CONVERSION
        'height': (raw['height'] is num)
            ? (raw['height'] as num).toDouble()
            : 0.0,

        // ✅ CUSTOM ADS
        'custom_ad_view_url': raw['custom_ad_view_url'] ?? '',
        'custom_ad_url': raw['custom_ad_url'] ?? '',
      };

      return AdData.fromJson(data);
    } catch (e, s) {
      '❌ Failed to parse AdData for $key: $e'.logD;
      s.toString().logD;
      return AdData.fromJson(_emptyAd());
    }
  }

  Map<String, dynamic> _emptyAd() => {
    'ad_id': '',
    'enabled': false,
    'ad_type': 'native',
    'template_type': 'small',
    'height': 0.0,
    'custom_ad_view_url': '',
    'custom_ad_url': '',
  };


  dynamic _get(String key, [dynamic defaultValue]) {
    return _appData[key] ?? defaultValue;
  }

  dynamic _getBtc(String key, [dynamic defaultValue]) {
    return _btcCloudManager[key] ?? defaultValue;
  }

  // ---------------------------------------------------------------------------
  // ADS
  // ---------------------------------------------------------------------------


  AdData get languageNative1 => _getAdData('language_native_1');

  AdData get languageNative2 => _getAdData('language_native_2');

  AdData get onboardingNative1 => _getAdData('onboarding_screen1');

  AdData get onboardingNative2 => _getAdData('onboarding_screen2');

  AdData get onboardingNative3 => _getAdData('onboarding_screen3');

  AdData get onboardingNative4 => _getAdData('onboarding_screen4');

  AdData get onboardingInter1 => _getAdData('onboarding_inter1');

  AdData get onboardingInter2 => _getAdData('onboarding_inter2');

  AdData get onboardingInter3 => _getAdData('onboarding_inter3');

  AdData get onboardingInter4 => _getAdData('onboarding_inter4');

  AdData get bottomNavBanner1 => _getAdData('bottom_nav_banner_1');

  AdData get bottomNavBanner2 => _getAdData('bottom_nav_banner_2');

  AdData get bottomNavBanner3 => _getAdData('bottom_nav_banner_3');

  AdData get bottomNavBanner4 => _getAdData('bottom_nav_banner_4');

  AdData get appNative => _getAdData('app_native');

  AdData get appInter => _getAdData('app_inter');

  AdData get appOpen => _getAdData('app_open');

  AdData get splashBanner => _getAdData('splash_banner');

  AdData get splashAppOpen => _getAdData('splash_app_open');

  AdData get step1Native => _getAdData('step1_native');

  AdData get step2Native => _getAdData('step2_native');

  AdData get step3Native => _getAdData('step3_native');

  AdData get step4Native => _getAdData('step4_native');

  AdData get step5Native => _getAdData('step5_native');

  AdData get step6Native => _getAdData('step6_native');

  AdData get step7Native => _getAdData('step7_native'); 
  
  AdData get step1Inter => _getAdData('step1_inter');

  AdData get step2Inter => _getAdData('step2_inter');

  AdData get step3Inter => _getAdData('step3_inter');

  AdData get step4Inter => _getAdData('step4_inter');

  AdData get step5Inter => _getAdData('step5_inter');

  AdData get step6Inter => _getAdData('step6_inter');

  AdData get step7Inter => _getAdData('step7_inter');

  AdData get recommendationNative => _getAdData('recommendation_native');

  AdData get loanNative => _getAdData('loan_native');

  AdData get fixedDepositNative => _getAdData('fixed_deposit_native');

  AdData get recurringDepositNative => _getAdData('recurring_deposit_native');

  AdData get documentsNative => _getAdData('documents_native');

  AdData get tipsNative => _getAdData('tips_native');

  AdData get temperatureNative => _getAdData('temperature_native');

  AdData get massNative => _getAdData('mass_native');

  AdData get speedNative => _getAdData('speed_native');

  AdData get lengthNative => _getAdData('length_native');

  AdData get languageNative => _getAdData('language_native');

  AdData get contactNative => _getAdData('contact_native');

  AdData get appReward => _getAdData('app_reward');

  int get appClickCounter => _get('app_click_counter', 10);

  String get privacyPolicyUrl => _get('privacy_policy_url', '');

  String get termsAndConditions => _get('terms_and_conditions', '');

  bool get showMultipleOnboarding => _get('show_multiple_onboarding', false);

  bool get skipOnBoarding => _get('skip_onboarding', false);

}
