import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_layout.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'welcome_screen');
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
        ..preloadOnboarding1Native()
        ..preloadWelcomeInter(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return OnboardingLayout(
            stepIndex: 0,
            buttonText: 'Continue',
            isLoading: provider.busy,
            onButtonPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'welcome_continue',
              );
              provider.nextTo1(context);
            },
            onSkip: () {
              AnalyticsManager.instance.logEvent(
                name: 'welcome_skip',
              );
              provider.skipToOnboarding1(context);
            },
            adSlot: AdSlot(ad: widget.inlineAd, safeAreaBottom: false),
            child: _WelcomeContent(),
          );
        },
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // App icon with gradient background
        Container(
          padding: EdgeInsets.all(AppSize.sp30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF06B6D4),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSize.r32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Assets.onboardingIcons.icWelcome.svg(),
        ),
        
        SizedBox(height: AppSize.h30),
        
        // Welcome title
        Text(
          'Welcome to FinWise',
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp30,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: AppSize.h5),
        
        // Description
        Text(
          'Your trusted companion for smarter\nfinancial decisions and personalized loan\nrecommendations',
          style: context.textTheme.bodyLarge?.copyWith(
            fontSize: AppSize.sp15,
            color: context.themeTextColors.descriptionColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: AppSize.h24),
      ],
    );
  }
}
