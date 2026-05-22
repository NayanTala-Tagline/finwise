import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../utils/navigation_helper.dart';
import '../../../utils/remote_config.dart';
import '../../../widgets/app_button.dart';
import 'loan_finder_app_bar.dart';

const int kLoanFinderTotalSteps = 7;

/// Common scaffold shared by every Loan-Finder screen.
///
/// Provides the gradient app bar, the centred "Step X of N" indicator, the
/// centred question title + subtitle and a docked primary [AppButton].
class LoanFinderLayout extends StatefulWidget {
  const LoanFinderLayout({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNextPressed,
    this.totalSteps = kLoanFinderTotalSteps,
    this.nextButtonText,
    this.adSlot,
    this.isLoading = false,
    this.buttonBottom,
  });

  final int stepIndex;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNextPressed;
  final String? nextButtonText;

  /// Optional inline (native/banner) ad rendered around the Next button.
  final Widget? adSlot;

  /// When true, the Next button shows a spinner and ignores taps — used while
  /// the transition interstitial is loading / showing.
  final bool isLoading;

  /// When true, the Next button sits **below** the native ad. When false, it
  /// sits **above** the native ad. When null (default) the value is read from
  /// Remote Config via `step_N_button_bottom`.
  final bool? buttonBottom;

  bool resolveButtonBottom() {
    if (buttonBottom != null) return buttonBottom!;
    final rc = RemoteConfigService.instance;
    return switch (stepIndex) {
      0 => rc.step1ButtonBottom,
      1 => rc.step2ButtonBottom,
      2 => rc.step3ButtonBottom,
      3 => rc.step4ButtonBottom,
      4 => rc.step5ButtonBottom,
      5 => rc.step6ButtonBottom,
      6 => rc.step7ButtonBottom,
      _ => false,
    };
  }

  // Tracks the last progress value shown so the next screen can animate
  // smoothly from there rather than restarting at zero. Survives across
  // screen pushes inside the loan-finder flow.
  static double _lastProgress = 0;

  @override
  State<LoanFinderLayout> createState() => _LoanFinderLayoutState();
}

class _LoanFinderLayoutState extends State<LoanFinderLayout> {
  late final double _fromProgress;
  late final double _toProgress;

  @override
  void initState() {
    super.initState();
    _toProgress = (widget.stepIndex + 1) / widget.totalSteps;
    // If the user re-enters the flow (or somehow lands on a lower step than
    // the cached value), restart the bar from zero rather than animating
    // backwards.
    final cached = LoanFinderLayout._lastProgress;
    _fromProgress = cached > _toProgress ? 0 : cached;
    LoanFinderLayout._lastProgress = _toProgress;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      appBar: const LoanFinderAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSize.h12),
            Padding(
              padding:   EdgeInsets.symmetric(horizontal: AppSize.w30),
              child: Row(
                children: [
                  Expanded(
                    child: _AnimatedStepProgress(
                      from: _fromProgress,
                      to: _toProgress,
                    )
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 80.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  SizedBox(width: AppSize.w20,),
                  _StepCounter(
                    stepIndex: widget.stepIndex,
                    totalSteps: widget.totalSteps,
                  )
                      .animate()
                      .fadeIn(duration: 380.ms, curve: Curves.easeOut)
                      .slideY(
                    begin: -0.5,
                    end: 0,
                    duration: 520.ms,
                    curve: Curves.easeOutBack,
                  )
                      .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 520.ms,
                    curve: Curves.easeOutBack,
                  ),
                 ],
              ),
            ),
            SizedBox(height: AppSize.h20),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: textColors.textColor,
                fontWeight: FontWeight.w700,
                fontSize: AppSize.sp18,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 450.ms)
                .slideY(
                  begin: 0.4,
                  end: 0,
                  delay: 150.ms,
                  duration: 650.ms,
                  curve: Curves.easeOutCubic,
                )
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                  delay: 150.ms,
                  duration: 650.ms,
                  curve: Curves.easeOutBack,
                )
                .blurXY(
                  begin: 6,
                  end: 0,
                  delay: 150.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),
            SizedBox(height: AppSize.h4),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: textColors.descriptionColor,
                fontSize: AppSize.sp12,
                fontWeight: FontWeight.w400,
              ),
            )
                .animate()
                .fadeIn(delay: 280.ms, duration: 450.ms)
                .slideY(
                  begin: 0.4,
                  end: 0,
                  delay: 280.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
            SizedBox(height: AppSize.h20),
            Expanded(
              child: ClipRect(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Builder(builder: (_) {
          final buttonBelowAd = widget.resolveButtonBottom();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!buttonBelowAd) _buildNextButton(context),
              ?widget.adSlot,
              if (buttonBelowAd) _buildNextButton(context),
            ],
          );
        }),
      ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                offset: Offset(1,0),
                blurRadius: 2
            )
          ]
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSize.w20,
          AppSize.h8,
          AppSize.w20,
          AppSize.h15,
        ),
        child: AppButton(
          text: widget.nextButtonText ?? 'Continue',
          isLoading: widget.isLoading,
          onPressed: widget.onNextPressed,
          suffixIcon: const Icon(
            Icons.arrow_forward_ios_sharp,
            color: Colors.white,
            size: 18,
          ),
        )
            .animate()
            .fadeIn(delay: 380.ms, duration: 450.ms)
            .slideY(
              begin: 0.7,
              end: 0,
              delay: 380.ms,
              duration: 620.ms,
              curve: Curves.easeOutBack,
            )
            .scale(
              begin: const Offset(0.94, 0.94),
              end: const Offset(1, 1),
              delay: 380.ms,
              duration: 620.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}

/// "Step X of N" pill with a soft tinted background so it reads as a chip.
class _StepCounter extends StatelessWidget {
  const _StepCounter({required this.stepIndex, required this.totalSteps});

  final int stepIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return Text(
      '${stepIndex + 1} of ${totalSteps}',
       style: context.textTheme.titleMedium?.copyWith(
        color: textColors.textColor,
        fontSize: AppSize.sp12,
         letterSpacing: 0.2,
      ),
    );
  }
}

/// Progress bar that tweens from the previous step's value to the current
/// one with a gentle elastic curve and a brand-coloured shimmer that loops.
class _AnimatedStepProgress extends StatelessWidget {
  const _AnimatedStepProgress({required this.from, required this.to});

  final double from;
  final double to;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    const tweenDuration = Duration(milliseconds: 850);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.r6),
      child: SizedBox(
        height: AppSize.h6,
        child: Stack(
          children: [
            // Track
            Container(
              decoration: BoxDecoration(
                color: Color(0xffBBC4CE),
                borderRadius: BorderRadius.circular(AppSize.r6),
              ),
            ),
            // Animated fill
            LayoutBuilder(
              builder: (ctx, constraints) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: from, end: to),
                  duration: tweenDuration,
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) {
                    return Container(
                      width: constraints.maxWidth * value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, Color(0xff0D9488)],
                        ),
                        borderRadius: BorderRadius.circular(AppSize.r6),
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .shimmer(
                          delay: 400.ms,
                          duration: 1600.ms,
                          color: colors.whiteColor.withValues(alpha: 0.55),
                        );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
