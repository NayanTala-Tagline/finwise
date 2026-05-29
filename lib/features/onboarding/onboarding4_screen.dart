import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/ad_slot.dart';
import '../language_screen/provider/locale_provider.dart';
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_layout.dart';

class Onboarding4Screen extends StatefulWidget {
  const Onboarding4Screen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Onboarding4Screen> createState() => _Onboarding4ScreenState();
}

class _Onboarding4ScreenState extends State<Onboarding4Screen> {
  String selectedLanguageCode = 'en';
  int selectedLanguageIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'onboarding4_screen');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeSelectedLanguage();
      _initialized = true;
    }
  }

  void _initializeSelectedLanguage() {
    final languageProvider = context.read<LocaleProvider>();
    selectedLanguageCode = languageProvider.getCurrentLocaleCode() ?? 'en';
    
    final languages = _getLanguages();
    selectedLanguageIndex = languages.indexWhere(
      (lang) => lang.code == selectedLanguageCode,
    );
    if (selectedLanguageIndex == -1) {
      selectedLanguageCode = 'en';
      selectedLanguageIndex = 0;
    }
  }

  List<_Language> _getLanguages() {
    return [
      _Language('en', context.l10n.languageEnglish, 'English'),
      _Language('hi', context.l10n.languageHindi, 'हिंदी'),
      _Language('mr', context.l10n.languageMarathi, 'मराठी'),
      _Language('ta', context.l10n.languageTamil, 'தமிழ்'),
      _Language('te', context.l10n.languageTelugu, 'తెలుగు'),
      _Language('bn', context.l10n.languageBengali, 'বাংলা'),
    ];
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  Future<void> _handleStart(OnboardingProvider provider) async {
    final languageProvider = context.read<LocaleProvider>();
    await languageProvider.setLocale(
      Locale(selectedLanguageCode),
      selectedLanguageIndex,
      true,
    );

    AnalyticsManager.instance.logEvent(
      name: 'onboarding_next',
      parameters: {'language': selectedLanguageCode, 'step': 4},
    );
    
    if (!mounted) return;
    provider.nextTo5(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider()
        ..preloadOnboarding5Native()
        ..preloadInter4(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return OnboardingLayout(
            stepIndex: 4,
            buttonText: context.l10n.onboarding1Continue,
            isLoading: provider.busy,
            onButtonPressed: () => _handleStart(provider),
            onBackPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_back',
                parameters: const {'step': 4},
              );
              NavigationHelper().handleBackPress(context);
            },
            adSlot: AdSlot(ad: widget.inlineAd, safeAreaBottom: false),
            child: _LanguageSelectionContent(
              selectedLanguageCode: selectedLanguageCode,
              languages: _getLanguages(),
              onLanguageSelected: (code, index) {
                setState(() {
                  selectedLanguageCode = code;
                  selectedLanguageIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class _LanguageSelectionContent extends StatelessWidget {
  final String selectedLanguageCode;
  final List<_Language> languages;
  final Function(String, int) onLanguageSelected;

  const _LanguageSelectionContent({
    required this.selectedLanguageCode,
    required this.languages,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
      child: Column(
        children: [
          SizedBox(height: AppSize.h40),
          Container(
            padding: EdgeInsets.all(AppSize.sp30),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AppSize.r24),
            ),
            child: Assets.onboardingIcons.icLanguage.svg(),
          ),
          SizedBox(height: AppSize.h32),
          Text(
            context.l10n.onboarding4Title,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp30,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h12),
          Text(
            context.l10n.onboarding4Subtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp15,
              color: context.themeTextColors.descriptionColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h40),
          _LanguageGrid(
            selectedLanguageCode: selectedLanguageCode,
            languages: languages,
            onLanguageSelected: onLanguageSelected,
          ),
          SizedBox(height: AppSize.h24),
        ],
      ),
    );
  }
}

class _LanguageGrid extends StatelessWidget {
  final String selectedLanguageCode;
  final List<_Language> languages;
  final Function(String, int) onLanguageSelected;

  const _LanguageGrid({
    required this.selectedLanguageCode,
    required this.languages,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSize.w12,
        mainAxisSpacing: AppSize.h12,
        childAspectRatio: 1.7,
      ),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        return _LanguageCard(
          language: languages[index],
          isSelected: selectedLanguageCode == languages[index].code,
          onTap: () => onLanguageSelected(languages[index].code, index),
        );
      },
    );
  }
}

class _Language {
  final String code;
  final String name;
  final String nativeName;

  _Language(this.code, this.name, this.nativeName);
}

class _LanguageCard extends StatelessWidget {
  final _Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSize.h20,
          horizontal: AppSize.w16,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [context.themeColors.primary,Color(0xff153885),]) : LinearGradient(colors: [Colors.white,Colors.white]),
          borderRadius: BorderRadius.circular(AppSize.r16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp14,
                    color: isSelected ? context.themeTextColors.secondaryTextColor : null
                  ),
                  textAlign: TextAlign.center,
                ),
                if(isSelected)
                Icon(Icons.done,color: Colors.white,size: AppSize.sp20,)
              ],
            ),
            SizedBox(height: AppSize.h4),
            Text(
              language.nativeName,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: AppSize.sp18,
                  color: isSelected ? context.themeTextColors.secondaryTextColor : null
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
