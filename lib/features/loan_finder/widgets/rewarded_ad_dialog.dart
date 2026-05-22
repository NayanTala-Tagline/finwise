import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/app_button.dart';

/// Branded "watch a rewarded ad" prompt. White card, gradient play-icon at
/// the top with a continuous pulse + shimmer, centred title/description and
/// two actions (filled "Watch AD" / outlined "Cancel").
///
/// The rewarded-ad integration itself is deferred — [onWatchAd] fires after
/// the dialog is dismissed so the caller can wire it up later.
class RewardedAdDialog extends StatelessWidget {
  const RewardedAdDialog({
    super.key,
    required this.onWatchAd,
    this.onCancel,
  });

  final VoidCallback onWatchAd;
  final VoidCallback? onCancel;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onWatchAd,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RewardedAdDialog(
        onWatchAd: onWatchAd,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    final animatedIcon = SizedBox(
      width: AppSize.w100,
      height: AppSize.h100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo ring — expands outward and fades, on a loop.
          Container(
            width: AppSize.w64,
            height: AppSize.h64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.18),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.35, 1.35),
                duration: 1400.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1400.ms, curve: Curves.easeOut),
          // Gradient pill with play arrow — gentle pulse.
          Container(
            width: AppSize.w64,
            height: AppSize.h64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  blurRadius: AppSize.r16,
                  offset: Offset(0, AppSize.h6),
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: colors.whiteColor,
              size: AppSize.sp36,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );

    return Dialog(
      backgroundColor: colors.whiteColor,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.r20),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSize.w20,
          AppSize.h24,
          AppSize.w20,
          AppSize.h20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            animatedIcon,
            SizedBox(height: AppSize.h18),
            Text(
              'Get Loan EMI',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: textColors.textColor,
                fontWeight: FontWeight.w700,
                fontSize: AppSize.sp18,
              ),
            ),
            SizedBox(height: AppSize.h10),
            Text(
              'Watch a quick video and unlock useful loan tips designed to help you plan better.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: textColors.descriptionColor,
                fontSize: AppSize.sp12,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSize.h22),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Watch AD',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onWatchAd();
                    },
                  ),
                ),
                SizedBox(width: AppSize.w12),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                    child: Container(
                      height: AppSize.h50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.whiteColor,
                        borderRadius: BorderRadius.circular(AppSize.r34),
                        border: Border.all(
                          color: colors.borderColor2,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: textColors.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: AppSize.sp16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
