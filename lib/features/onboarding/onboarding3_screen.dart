import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
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

class Onboarding3Screen extends StatefulWidget {
  const Onboarding3Screen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'onboarding3_screen');
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
        ..preloadOnboarding4Native()
        ..preloadInter3(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return OnboardingLayout(
            stepIndex: 3,
            buttonText: context.l10n.onboarding1Continue,
            isLoading: provider.busy,
            onButtonPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_next',
                parameters: const {'step': 3},
              );
              provider.nextTo4(context);
            },
            onBackPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_back',
                parameters: const {'step': 3},
              );
              NavigationHelper().handleBackPress(context);
            },
            adSlot: AdSlot(ad: widget.inlineAd, safeAreaBottom: false),
            child: _ReadyToStartContent(),
          );
        },
      ),
    );
  }
}

class _ReadyToStartContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppSize.h40),
          Container(
            padding: EdgeInsets.all(AppSize.sp30),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(AppSize.r24),
            ),
            child: Assets.onboardingIcons.icVerification.svg(),
          ),
          SizedBox(height: AppSize.h32),
          Text(
            context.l10n.onboarding3Title,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp30,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h12),
          Text(
            context.l10n.onboarding3Subtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp15,
              color: context.themeTextColors.descriptionColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h40),
          Container(
            margin: EdgeInsets.symmetric(horizontal: AppSize.w70),
            padding: EdgeInsets.symmetric(horizontal: AppSize.w18,vertical: AppSize.h10),
            decoration: BoxDecoration(
              color:   Color(0xFF059669).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSize.r20),
             ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.onboardingIcons.icVerification.svg(width: AppSize.w14,height: AppSize.h18),
                SizedBox(width: AppSize.w10),
                Flexible(
                  child: Text(
                    context.l10n.onboarding3Encryption,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontSize: AppSize.sp14,
                      color: Color(0xff059669),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.h24),
        ],
      ),
    );
  }
}
