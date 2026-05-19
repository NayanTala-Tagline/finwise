import 'dart:async';
import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';
import 'app_button.dart';

class RewardAdBottomSheet extends StatefulWidget {
  final VoidCallback onSupportUs;
  final VoidCallback onCancel;
  final int timerSeconds;

  const RewardAdBottomSheet({
    super.key,
    required this.onSupportUs,
    required this.onCancel,
    this.timerSeconds = 3,
  });

  @override
  State<RewardAdBottomSheet> createState() => _RewardAdBottomSheetState();
}

class _RewardAdBottomSheetState extends State<RewardAdBottomSheet> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timerSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        Navigator.of(context).pop();
        widget.onSupportUs();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.backgroundColor2, colors.backgroundColor],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.r24)),
        border: Border.all(color: colors.borderColor, width: 1),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSize.w20,
        AppSize.h12,
        AppSize.w20,
        AppSize.h20 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.w40,
            height: AppSize.h4,
            decoration: BoxDecoration(
              color: colors.whiteColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppSize.r2),
            ),
          ),
          SizedBox(height: AppSize.h20),

          Container(
            width: AppSize.w80,
            height: AppSize.w80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.18),
              border: Border.all(
                color: colors.borderColor2.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: EdgeInsets.all(AppSize.w14),
            child: Icon(Icons.gif_box),
          ),
          SizedBox(height: AppSize.h16),

          Text(
            'Earn a Reward',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w700,
              color: colors.whiteColor,
            ),
          ),
          SizedBox(height: AppSize.h8),

          Text(
            'Watch a short ad to claim your reward and keep mining at full speed.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: AppSize.sp14,
              height: 1.4,
              color: textColors.descriptionColor,
            ),
          ),
          SizedBox(height: AppSize.h18),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _remainingSeconds > 0
                ? Container(
                    key: ValueKey(_remainingSeconds),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.w14,
                      vertical: AppSize.h8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSize.r20),
                      border: Border.all(
                        color: colors.borderColor2.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: AppSize.sp16,
                          color: colors.secondary,
                        ),
                        SizedBox(width: AppSize.w6),
                        Text(
                          'Auto-starting in $_remainingSeconds s',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: AppSize.sp13,
                            fontWeight: FontWeight.w600,
                            color: colors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: AppSize.h32),
          ),
          SizedBox(height: AppSize.h20),

          Row(
            children: [
              Expanded(
                child: _CancelButton(
                  onTap: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                    widget.onCancel();
                  },
                ),
              ),
              SizedBox(width: AppSize.w12),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'Get Reward',
                  borderRadius: AppSize.r25,
                  icon: Icon(
                    Icons.play_circle_fill_rounded,
                    color: colors.whiteColor,
                    size: AppSize.sp20,
                  ),
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                    widget.onSupportUs();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.r25),
      child: Container(
        height: AppSize.h48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.cardColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppSize.r25),
          border: Border.all(
            color: colors.borderColor.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
        child: Text(
          'Cancel',
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: AppSize.sp16,
            fontWeight: FontWeight.w600,
            color: colors.whiteColor.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the reward ad bottom sheet
Future<void> showRewardAdBottomSheet({
  required BuildContext context,
  required VoidCallback onSupportUs,
  required VoidCallback onCancel,
  int timerSeconds = 3,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => RewardAdBottomSheet(
      onSupportUs: onSupportUs,
      onCancel: onCancel,
      timerSeconds: timerSeconds,
    ),
  );
}
