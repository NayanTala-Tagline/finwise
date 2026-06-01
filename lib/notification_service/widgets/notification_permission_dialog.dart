import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../extension/ext_context.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';

/// Shown when notification permission is *not yet* permanently denied — gives
/// the user a friendly nudge to allow notifications before we trigger the
/// system request.
class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({
    super.key,
    required this.onAllow,
    this.onNotNow,
  });

  final VoidCallback onAllow;
  final VoidCallback? onNotNow;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAllow,
    VoidCallback? onNotNow,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotificationPermissionDialog(
        onAllow: onAllow,
        onNotNow: onNotNow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    final animatedBell = SizedBox(
      width: AppSize.w100,
      height: AppSize.h100,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
          Container(
            width: AppSize.w64,
            height: AppSize.h64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, Color(0xff153885)],
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
              Icons.notifications_active_rounded,
              color: colors.whiteColor,
              size: AppSize.sp34,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(
                begin: -0.04,
                end: 0.04,
                duration: 700.ms,
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
            animatedBell,
            SizedBox(height: AppSize.h12),
            Text(
              'Stay in updated',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: textColors.textColor,
                fontWeight: FontWeight.w700,
                fontSize: AppSize.sp18,
              ),
            ),
            SizedBox(height: AppSize.h10),
            Text(
              'Allow notifications so we can keep you posted on your loan application status and important updates.',
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
                    text: 'Allow',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAllow();
                    },
                  ),
                ),
                SizedBox(width: AppSize.w12),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).pop();
                      onNotNow?.call();
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
                        'Not Now',
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
