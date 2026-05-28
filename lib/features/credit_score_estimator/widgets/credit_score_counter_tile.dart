import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';

class CreditScoreCounterTile extends StatelessWidget {
  const CreditScoreCounterTile({
    super.key,
    required this.label,
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp16,
              color: context.themeTextColors.textColor,
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.remove,
          onTap: onDecrement,
          enabled: count > 0,
        ),
        SizedBox(width: AppSize.w16),
        SizedBox(
          width: AppSize.w24,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp16,
              fontWeight: FontWeight.w700,
              color: context.themeColors.primary,
            ),
          ),
        ),
        SizedBox(width: AppSize.w16),
        _CounterButton(icon: Icons.add, onTap: onIncrement, enabled: true),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap, required this.enabled});

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: AppSize.w28,
        height: AppSize.h28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Icon(icon, size: AppSize.sp16, color: Colors.black),
      ),
    );
  }
}
