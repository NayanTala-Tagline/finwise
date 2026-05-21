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
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_layout.dart';

class Onboarding4Screen extends StatefulWidget {
  const Onboarding4Screen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Onboarding4Screen> createState() => _Onboarding4ScreenState();
}

class _Onboarding4ScreenState extends State<Onboarding4Screen> {
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'onboarding4_screen');
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  Future<void> _handleStart(OnboardingProvider provider) async {
    AnalyticsManager.instance.logEvent(
      name: 'onboarding_next',
      parameters: {'language': selectedLanguage, 'step': 4},
    );
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
            buttonText: 'Continue',
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
              selectedLanguage: selectedLanguage,
              onLanguageSelected: (language) {
                setState(() {
                  selectedLanguage = language;
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
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const _LanguageSelectionContent({
    required this.selectedLanguage,
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
            'Choose Your\nLanguage',
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp30,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h12),
          Text(
            'Select your preferred language for the app',
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp15,
              color: context.themeTextColors.descriptionColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h40),
          _LanguageGrid(
            selectedLanguage: selectedLanguage,
            onLanguageSelected: onLanguageSelected,
          ),
          SizedBox(height: AppSize.h24),
        ],
      ),
    );
  }
}

class _LanguageGrid extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const _LanguageGrid({
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      _Language('English', 'English'),
      _Language('Hindi', 'हिंदी'),
      _Language('Marathi', 'मराठी'),
      _Language('Tamil', 'தமிழ்'),
      _Language('Telugu', 'తెలుగు'),
      _Language('Bengali', 'বাংলা'),
    ];

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
          isSelected: selectedLanguage == languages[index].name,
          onTap: () => onLanguageSelected(languages[index].name),
        );
      },
    );
  }
}

class _Language {
  final String name;
  final String nativeName;

  _Language(this.name, this.nativeName);
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
