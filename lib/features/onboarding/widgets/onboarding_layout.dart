import 'package:finwise/extension/ext_context.dart';
import 'package:finwise/utils/remote_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/app_size.dart';
import '../../../utils/navigation_helper.dart';
import '../../../widgets/app_button.dart';

const int kOnboardingTotal = 6;

class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.stepIndex,
    required this.child,
    required this.buttonText,
    required this.onButtonPressed,
    this.onBackPressed,
    this.onSkip,
    this.adSlot,
    this.buttonBottom,
    this.isLoading = false,
  });

  final int stepIndex;
  final Widget child;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSkip;
  final Widget? adSlot;
  final bool isLoading;
  final bool? buttonBottom;

  bool _resolveButtonBottom() {
    if (buttonBottom != null) return buttonBottom!;
    final rc = RemoteConfigService.instance;
    return switch (stepIndex) {
      1 => rc.onboarding1ButtonBottom,
      2 => rc.onboarding2ButtonBottom,
      3 => rc.onboarding3ButtonBottom,
      4 => rc.onboarding4ButtonBottom,
      5 => rc.onboarding5ButtonBottom,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final buttonBelowAd = _resolveButtonBottom();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          NavigationHelper().handleBackPress(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w20,
                  vertical: AppSize.h16,
                ),
                child: Row(

                  children: [
                    if(onBackPressed != null)
                    GestureDetector(
                      onTap: onBackPressed,
                      child: Icon(Icons.arrow_back_ios, color: Colors.black),
                    ),
                    Spacer(),
                    _DotsIndicator(activeIndex: stepIndex),
                  ],
                ),
              ),
              Expanded(child: Center(child: child)),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          bottom: true,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              if (!buttonBelowAd)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
                  child: AppButton(
                    text: buttonText,
                    isLoading: isLoading,
                    onPressed: onButtonPressed,
                    backgroundColor: context.colorScheme.primary,
                    suffixIcon: const Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              // if (adSlot != null) ...[
              //   const Divider(
              //     height: 1,
              //     thickness: 1,
              //     color: Color(0xFFD9D9D9),
              //   ),
              //   SizedBox(height: AppSize.h3),
              // ],
              ?adSlot,
              if (buttonBelowAd)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
                  child: AppButton(
                    text: buttonText,
                    isLoading: isLoading,
                    onPressed: onButtonPressed,
                    backgroundColor: context.colorScheme.primary,
                    suffixIcon: const Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(kOnboardingTotal, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(right: AppSize.w6),
          width: isActive ? AppSize.w30 : AppSize.w10,
          height: AppSize.h6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(AppSize.r4),
          ),
        );
      }),
    );
  }
}
