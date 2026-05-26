import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import 'tool_item.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({super.key, required this.item, this.iconBgColor, this.onTap});

  final ToolItem item;
  final Color? iconBgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w16,
          vertical: AppSize.h14,
        ),
        decoration: BoxDecoration(
          color: colors.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.r14),
          border: Border.all(color: Color(0xffF1F5F9))
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSize.sp9),
              decoration: BoxDecoration(
                color: iconBgColor ?? colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.r18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.05),
                    blurRadius: AppSize.r10,
                    // spreadRadius: AppSize.h4,
                    offset: Offset(0, AppSize.h6),
                  ),
                ],
              ),

              child: Center(
                child: item.icon.svg(
                  width: AppSize.w24,
                  height: AppSize.h24,
                ),
              ),
            ),
            SizedBox(width: AppSize.w14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: textColors.textColor,
                       fontSize: AppSize.sp16,
                    ),
                  ),
                  SizedBox(height: AppSize.h3),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: textColors.descriptionColor,
                      fontSize: AppSize.sp12,
                     ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSize.w8),
            Icon(
              Icons.arrow_forward_rounded,
              color: const Color(0xFF64748B),
              size: AppSize.sp20,
            ),
          ],
        ),
      ),
    );
  }
}
