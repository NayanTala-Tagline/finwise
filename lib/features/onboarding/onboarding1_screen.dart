import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            buttonText: context.l10n.onboarding1Continue,
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
              context.pop();

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
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                delay: 200.ms,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              ),
          SizedBox(height: AppSize.h25),
          Text(
            context.l10n.onboarding1Title,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp30,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOut),
          SizedBox(height: AppSize.h8),
          Text(
            context.l10n.onboarding1Subtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp15,
              color: context.themeTextColors.descriptionColor,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 500.ms)
              .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOut),
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
      _LoanType(context.l10n.homeLoanHome, Assets.onboardingIcons.icHome.svg(), const Color(0xFF3B82F6)),
      _LoanType(context.l10n.onboarding1Education, Assets.onboardingIcons.icEducation.svg(), const Color(0xFF10B981)),
      _LoanType(context.l10n.onboarding1Personal, Assets.onboardingIcons.icPersonal.svg(), const Color(0xFFEF4444)),
      _LoanType(context.l10n.onboarding1VehicleLoan, Assets.onboardingIcons.icVehicle.svg(), const Color(0xFF10B981)),
      _LoanType(context.l10n.onboarding1Business, Assets.onboardingIcons.icBusiness.svg(), const Color(0xFFF59E0B)),
    ];

    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
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
            final loanType = loanTypes[index];
            final isSelected = provider.isLoanTypeSelected(loanType.title);
            return _LoanTypeCard(
              loanType,
              isSelected: isSelected,
              onTap: () => provider.selectLoanType(loanType.title),
            )
                .animate()
                .fadeIn(delay: (700 + index * 80).ms, duration: 400.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  delay: (700 + index * 80).ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                );
          },
        );
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
  final bool isSelected;
  final VoidCallback onTap;

  const _LoanTypeCard(
    this.loanType, {
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: AppSize.h10,
          horizontal: AppSize.w16,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [context.themeColors.primary,Color(0xff153885),]) : LinearGradient(colors: [Colors.white,Colors.white]),
          borderRadius: BorderRadius.circular(AppSize.r16),
          border: Border.all(
            color:  const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSize.sp14),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2)
                    : loanType.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.r12),
              ),
              child: ColorFiltered(
                colorFilter: isSelected
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : ColorFilter.mode(loanType.color, BlendMode.srcIn),
                child: loanType.icon,
              ),
            ),
            SizedBox(height: AppSize.h12),
            Text(
              loanType.title,
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: AppSize.sp14,
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
