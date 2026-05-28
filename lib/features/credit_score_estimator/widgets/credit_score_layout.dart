import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../utils/remote_config.dart';
import '../../../widgets/app_button.dart';
import 'credit_score_app_bar.dart';

const int kCreditScoreTotalSteps = 6;

class CreditScoreLayout extends StatefulWidget {
  const CreditScoreLayout({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNextPressed,
    this.totalSteps = kCreditScoreTotalSteps,
    this.nextButtonText,
    this.isLastStep = false,
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
  final bool isLastStep;

  /// Optional inline ad rendered around the button in the bottom bar.
  final Widget? adSlot;

  /// When true the Continue/Calculate button shows a spinner and ignores taps.
  final bool isLoading;

  /// Overrides Remote Config button-below-ad placement when non-null.
  final bool? buttonBottom;

  bool resolveButtonBottom() {
    if (buttonBottom != null) return buttonBottom!;
    final rc = RemoteConfigService.instance;
    return switch (stepIndex) {
      0 => rc.csStep1ButtonBottom,
      1 => rc.csStep2ButtonBottom,
      2 => rc.csStep3ButtonBottom,
      3 => rc.csStep4ButtonBottom,
      4 => rc.csStep5ButtonBottom,
      5 => rc.csStep6ButtonBottom,
      _ => false,
    };
  }

  static double _lastProgress = 0;

  @override
  State<CreditScoreLayout> createState() => _CreditScoreLayoutState();
}

class _CreditScoreLayoutState extends State<CreditScoreLayout> {
  late final double _fromProgress;
  late final double _toProgress;

  @override
  void initState() {
    super.initState();
    _toProgress = (widget.stepIndex + 1) / widget.totalSteps;
    final cached = CreditScoreLayout._lastProgress;
    _fromProgress = cached > _toProgress ? 0 : cached;
    CreditScoreLayout._lastProgress = _toProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      appBar: CreditScoreAppBar(
        onBack: () {
          if (context.canPop()) context.pop();
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSize.h12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w30),
              child: Row(
                children: [
                  Expanded(
                    child: _AnimatedProgress(from: _fromProgress, to: _toProgress)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 400.ms),
                  ),
                  SizedBox(width: AppSize.w12),
                  Text(
                    '${widget.stepIndex + 1} of ${widget.totalSteps}',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: AppSize.sp12,
                      color: context.themeTextColors.textColor,
                    ),
                  ).animate().fadeIn(duration: 380.ms),
                ],
              ),
            ),
            SizedBox(height: AppSize.h20),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: AppSize.sp22,
              ),
            ).animate().fadeIn(delay: 120.ms, duration: 400.ms),
            SizedBox(height: AppSize.h4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: AppSize.sp14,
                  color: context.themeTextColors.descriptionColor,
                ),
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 400.ms),
            SizedBox(height: AppSize.h16),
            Expanded(child: widget.child),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Builder(builder: (_) {
          final buttonBelowAd = widget.resolveButtonBottom();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!buttonBelowAd) _buildBottomButtons(context),
              if (widget.adSlot != null) widget.adSlot!,
              if (buttonBelowAd) _buildBottomButtons(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x26000000), offset: Offset(0, -1), blurRadius: 4)],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h10, AppSize.w20, AppSize.h10),
        child: widget.stepIndex == 0
            ? AppButton(
                text: widget.nextButtonText ?? 'Continue',
                isLoading: widget.isLoading,
                onPressed: widget.onNextPressed,
                suffixIcon: Icon(Icons.arrow_forward_ios_sharp, color: Colors.white, size: AppSize.sp18),
              )
            : Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Previous',
                      onPressed: () {
                        if (context.canPop()) context.pop();
                      },
                      isOutlined: true,
                      prefixIcon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black, size: AppSize.sp18),
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      text: widget.nextButtonText ?? (widget.isLastStep ? 'Calculate' : 'Continue'),
                      isLoading: widget.isLoading,
                      onPressed: widget.onNextPressed,
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Colors.white,
                        size: AppSize.sp18,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AnimatedProgress extends StatelessWidget {
  const _AnimatedProgress({required this.from, required this.to});

  final double from;
  final double to;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.r6),
      child: SizedBox(
        height: AppSize.h6,
        child: Stack(
          children: [
            Container(color: const Color(0xFFBBC4CE)),
            LayoutBuilder(
              builder: (_, constraints) => TweenAnimationBuilder<double>(
                tween: Tween(begin: from, end: to),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Container(
                  width: constraints.maxWidth * value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.themeColors.primary, const Color(0xFF0D9488)],
                    ),
                    borderRadius: BorderRadius.circular(AppSize.r6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
