import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';

class CreditScoreOptionTile extends StatelessWidget {
  const CreditScoreOptionTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: AppSize.h58,
        padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.r12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          gradient: selected
              ? LinearGradient(colors: [context.themeColors.primary, const Color(0xFF153885)])
              : const LinearGradient(colors: [Colors.white, Color(0xFFE7F1FF)]),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: AppSize.sp14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : context.themeTextColors.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.sp11,
                      color: selected ? Colors.white70 : context.themeTextColors.descriptionColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: selected
                  ? Icon(Icons.check_circle_rounded, color: Colors.white, size: AppSize.sp20, key: const ValueKey('check'))
                  : SizedBox(width: AppSize.w20, key: const ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
