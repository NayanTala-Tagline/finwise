import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:finwise/routes/app_router.dart';
 import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/app_button.dart';

/// Submission-success dialog ("Congratulation"). Themed in brand peach with a
/// trophy badge that pops in + bounces, plus a one-shot confetti burst.
class LoanSubmittedDialog extends StatefulWidget {
  const LoanSubmittedDialog({super.key, this.onOk});

  final VoidCallback? onOk;

  static Future<void> show(BuildContext context, {VoidCallback? onOk}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoanSubmittedDialog(onOk: onOk),
    );
  }

  @override
  State<LoanSubmittedDialog> createState() => _LoanSubmittedDialogState();
}

class _LoanSubmittedDialogState extends State<LoanSubmittedDialog> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return Dialog(
      backgroundColor: colors.whiteColor,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.r20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSize.w20,
              AppSize.h24,
              AppSize.w20,
              AppSize.h20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AnimatedBadge(
                  primary: colors.primary,
                  secondary: Color(0xFF153885),
                  whiteColor: colors.whiteColor,
                ),
                SizedBox(height: AppSize.h16),
                Text(
                  context.l10n.loanSubmittedTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: textColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSize.sp20,
                  ),
                ),
                SizedBox(height: AppSize.h14),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w8),
                  child: Text(
                    context.l10n.loanSubmittedMessage,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: textColors.descriptionColor,
                      fontWeight: FontWeight.w400,
                      fontSize: AppSize.sp13,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: AppSize.h20),
                AppButton(
                  text: context.l10n.loanSubmittedOk,
                  onPressed: () {
                    context.pop();
                    widget.onOk?.call();
                   context.goNamed(AppRoutes.home);

                  },
                ),
              ],
            ),
          ),
          // Confetti emitter sits above the dialog, blasting downward.
          Positioned(
            top: -AppSize.h20,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              maxBlastForce: 18,
              minBlastForce: 8,
              emissionFrequency: 0.04,
              numberOfParticles: 18,
              gravity: 0.25,
              shouldLoop: false,
              colors: [
                colors.primary,
                Color(0xFF153885),
                Color(0xFF153885).withValues(alpha: 0.5),
                colors.whiteColor,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({
    required this.primary,
    required this.secondary,
    required this.whiteColor,
  });

  final Color primary;
  final Color secondary;
  final Color whiteColor;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: AppSize.w72,
          height: AppSize.h72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, secondary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.35),
                blurRadius: AppSize.r18,
                offset: Offset(0, AppSize.h6),
              ),
            ],
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            color: whiteColor,
            size: AppSize.sp40,
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .shake(duration: 500.ms, hz: 4, rotation: 0.05);
  }
}

