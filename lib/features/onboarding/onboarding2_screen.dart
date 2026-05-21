import 'dart:async';

import 'package:ad_manager/inline_ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/ad_slot.dart';
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_layout.dart';

class Onboarding2Screen extends StatefulWidget {
  const Onboarding2Screen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Onboarding2Screen> createState() => _Onboarding2ScreenState();
}

class _Onboarding2ScreenState extends State<Onboarding2Screen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'onboarding2_screen');
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider()
        ..preloadOnboarding3Native()
        ..preloadInter2(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return OnboardingLayout(
            stepIndex: 2,
            buttonText: 'Continue',
            isLoading: provider.busy,
            onButtonPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_next',
                parameters: const {'step': 2},
              );
              provider.nextTo3(context);
            },
            onBackPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_back',
                parameters: const {'step': 2},
              );
              NavigationHelper().handleBackPress(context);
            },
            adSlot: AdSlot(ad: widget.inlineAd, safeAreaBottom: false),
            child: _SmartFinancialContent(),
          );
        },
      ),
    );
  }
}

class _SmartFinancialContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:   EdgeInsets.symmetric(horizontal: AppSize.w20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: AppSize.h40),
            Container(
              padding: EdgeInsets.all(AppSize.sp30),
              decoration: BoxDecoration(
                color:   Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(AppSize.r24),
              ),
              child: Assets.onboardingIcons.icMakeSmart.svg(),
            ),
            SizedBox(height: AppSize.h30),
            Text(
              'Make Smart Financial\nDecisions',
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: AppSize.sp30,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSize.h12),
            Text(
              'Get personalized insights, compare offers\nfrom top lenders, and choose the best\noption for your needs',
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: AppSize.sp15,
                color: context.themeTextColors.descriptionColor,
              ),
      
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSize.h30),
            _FeaturesList(),
           ],
        ),
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      'Compare rates from 20+ lenders',
      'Instant eligibility check',
      'Expert guidance at every step',
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: EdgeInsets.only(bottom: AppSize.h12),
                child: _FeatureItem(feature),
              ))
          .toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSize.sp5),
          decoration: BoxDecoration(
            color:   Color(0xFF059669).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: AppSize.sp18,
            color:   Color(0xFF059669),
          ),
        ),
        SizedBox(width: AppSize.w10),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp16,
              color: context.themeTextColors.descriptionColor,
            ),

          ),
        ),
      ],
    );
  }
}
