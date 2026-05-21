import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_layout.dart';

class Onboarding1Screen extends StatefulWidget {
  const Onboarding1Screen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Onboarding1Screen> createState() => _Onboarding1ScreenState();
}

class _Onboarding1ScreenState extends State<Onboarding1Screen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'onboarding1_screen');
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
        ..preloadOnboarding2Native()
        ..preloadInter1(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return OnboardingLayout(
            stepIndex: 1,
            buttonText: 'Continue',
            isLoading: provider.busy,
            onButtonPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_next',
                parameters: const {'step': 1},
              );
              provider.nextTo2(context);
            },
            onBackPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_back',
                parameters: const {'step': 2},
              );
              NavigationHelper().handleBackPress(context);
            },
            adSlot: AdSlot(ad: widget.inlineAd, safeAreaBottom: false),
            child: _ExploreLoanTypesContent(),
          );
        },
      ),
    );
  }
}

class _ExploreLoanTypesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
      child: Column(
        children: [
          SizedBox(height: AppSize.h10),
          Container(
            padding: EdgeInsets.all(AppSize.sp30),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AppSize.r24),
            ),
            child: Assets.onboardingIcons.icStars.svg(),
          ),
          SizedBox(height: AppSize.h25),
          Text(
            'Explore Loan Types',
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp30,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h8),
          Text(
            'From home loans to education financing,\nwe help you find the perfect match',
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp15,
              color: context.themeTextColors.descriptionColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h20),
          _LoanTypeGrid(),
         ],
      ),
    );
  }
}

class _LoanTypeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loanTypes = [
      _LoanType(
        'Home Loan',
        Assets.onboardingIcons.icHome.svg(),
        const Color(0xFF3B82F6),
      ),
      _LoanType(
        'Education',
        Assets.onboardingIcons.icEducation.svg(),
        const Color(0xFF10B981),
      ),
      _LoanType(
        'Personal',
        Assets.onboardingIcons.icPersonal.svg(),
        const Color(0xFFEF4444),
      ),
      _LoanType(
        'Vehicle Loan',
        Assets.onboardingIcons.icVehicle.svg(),
        const Color(0xFF10B981),
      ),
      _LoanType(
        'Business',
        Assets.onboardingIcons.icBusiness.svg(),
        const Color(0xFFF59E0B),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSize.w18,
        mainAxisSpacing: AppSize.h18,
        childAspectRatio: 1.1,
      ),
      itemCount: loanTypes.length,
      itemBuilder: (context, index) {
        return _LoanTypeCard(loanTypes[index]);
      },
    );
  }
}

class _LoanType {
  final String title;
  final Widget icon;
  final Color color;

  _LoanType(this.title, this.icon, this.color);
}

class _LoanTypeCard extends StatelessWidget {
  final _LoanType loanType;

  const _LoanTypeCard(this.loanType);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSize.h10,
        horizontal: AppSize.w16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        border: Border.all(color:   Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.sp14),
            decoration: BoxDecoration(
              color: loanType.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.r12),
            ),
            child: loanType.icon,
          ),
          SizedBox(height: AppSize.h12),
          Text(
            loanType.title,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp14,
            ),

            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
