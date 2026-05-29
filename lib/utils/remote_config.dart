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


  // AdData get languageNative1 => _getAdData('language_native_1');
  //
  // AdData get languageNative2 => _getAdData('language_native_2');

  AdData get welcomeNative => _getAdData('welcome_native');

  AdData get welcomeInter => _getAdData('welcome_inter');

  AdData get onboardingNative1 => _getAdData('onboarding_screen1');

  AdData get onboardingNative2 => _getAdData('onboarding_screen2');

  AdData get onboardingNative3 => _getAdData('onboarding_screen3');

  AdData get onboardingNative4 => _getAdData('onboarding_screen4');

  AdData get onboardingNative5 => _getAdData('onboarding_screen5');

  AdData get onboardingInter1 => _getAdData('onboarding_inter1');

  AdData get onboardingInter2 => _getAdData('onboarding_inter2');

  AdData get onboardingInter3 => _getAdData('onboarding_inter3');

  AdData get onboardingInter4 => _getAdData('onboarding_inter4');

  AdData get onboardingInter5 => _getAdData('onboarding_inter5');

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

  AdData get creditCardStep1Native => _getAdData('credit_card_step1_native');

  AdData get creditCardStep2Native => _getAdData('credit_card_step2_native');

  AdData get creditCardStep3Native => _getAdData('credit_card_step3_native');

  AdData get creditCardStep4Native => _getAdData('credit_card_step4_native');

  AdData get creditCardStep5Native => _getAdData('credit_card_step5_native');

  AdData get creditCardStep6Native => _getAdData('credit_card_step6_native');

  AdData get creditCardStep1Inter => _getAdData('credit_card_step1_inter');

  AdData get creditCardStep2Inter => _getAdData('credit_card_step2_inter');

  AdData get creditCardStep3Inter => _getAdData('credit_card_step3_inter');

  AdData get creditCardStep4Inter => _getAdData('credit_card_step4_inter');

  AdData get creditCardStep5Inter => _getAdData('credit_card_step5_inter');

  AdData get creditCardStep6Inter => _getAdData('credit_card_step6_inter');

  AdData get recommendationNative => _getAdData('recommendation_native');

  AdData get creditScoreResultNative => _getAdData('credit_score_result_native');

  AdData get loanNative => _getAdData('loan_native');

  AdData get fixedDepositNative => _getAdData('fixed_deposit_native');

  AdData get fixedDepositCalculatorNative => _getAdData('fixed_deposit_calculator_native');

  AdData get fixedDepositResultNative => _getAdData('fixed_deposit_result_native');

  AdData get recurringDepositNative => _getAdData('recurring_deposit_native');

  AdData get recurringDepositCalculatorNative => _getAdData('recurring_deposit_calculator_native');

  AdData get recurringDepositResultNative => _getAdData('recurring_deposit_result_native');

  AdData get documentsNative => _getAdData('documents_native');

  AdData get tipsNative => _getAdData('tips_native');

  AdData get temperatureNative => _getAdData('temperature_native');

  AdData get massNative => _getAdData('mass_native');

  AdData get speedNative => _getAdData('speed_native');

  AdData get lengthNative => _getAdData('length_native');

  AdData get languageNative => _getAdData('language_native');

  AdData get contactNative => _getAdData('contact_native');

  AdData get currencyNative => _getAdData('currency_native');

  AdData get loanCalculatorNative => _getAdData('loan_calculator_native');

  AdData get loanCalculatorResultNative => _getAdData('loan_calculator_result_native');

  AdData get bottomHome => _getAdData('bottom_home');
  AdData get bottomTool => _getAdData('bottom_tool');
  AdData get bottomCompare => _getAdData('bottom_compare');
  AdData get bottomSetting => _getAdData('bottom_setting');

  bool get onboarding1ButtonBottom => _get('onboarding_1_button_bottom', false);
  bool get onboarding2ButtonBottom => _get('onboarding_2_button_bottom', false);
  bool get onboarding3ButtonBottom => _get('onboarding_3_button_bottom', false);
  bool get onboarding4ButtonBottom => _get('onboarding_4_button_bottom', false);
  bool get onboarding5ButtonBottom => _get('onboarding_5_button_bottom', false);

  bool get step1ButtonBottom => _get('step_1_button_bottom', false);
  bool get step2ButtonBottom => _get('step_2_button_bottom', false);
  bool get step3ButtonBottom => _get('step_3_button_bottom', false);
  bool get step4ButtonBottom => _get('step_4_button_bottom', false);
  bool get step5ButtonBottom => _get('step_5_button_bottom', false);
  bool get step6ButtonBottom => _get('step_6_button_bottom', false);
  bool get step7ButtonBottom => _get('step_7_button_bottom', false);

  bool get csStep1ButtonBottom => _get('cs_step_1_button_bottom', false);
  bool get csStep2ButtonBottom => _get('cs_step_2_button_bottom', false);
  bool get csStep3ButtonBottom => _get('cs_step_3_button_bottom', false);
  bool get csStep4ButtonBottom => _get('cs_step_4_button_bottom', false);
  bool get csStep5ButtonBottom => _get('cs_step_5_button_bottom', false);
  bool get csStep6ButtonBottom => _get('cs_step_6_button_bottom', false);


  AdData get appReward => _getAdData('app_reward');

  int get appClickCounter => _get('app_click_counter', 10);

  String get privacyPolicyUrl => _get('privacy_policy_url', '');

  String get termsAndConditions => _get('terms_and_conditions', '');

  bool get showMultipleOnboarding => _get('show_multiple_onboarding', false);

  bool get showOnboardingOrganicInstall => _get('show_onboarding_organic_install', false);

  bool get skipOnBoarding => _get('skip_onboarding', false);

}
