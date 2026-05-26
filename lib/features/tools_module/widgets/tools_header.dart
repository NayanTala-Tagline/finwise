import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/app_summary_background.dart';

class ToolsHeader extends StatelessWidget {
  const ToolsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSummaryBackground(
      gradientColors: [context.themeColors.primary, const Color(0xFF153885)],
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(AppSize.r24),
        bottomRight: Radius.circular(AppSize.r24),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSize.w20,
            AppSize.h20,
            AppSize.w20,
            AppSize.h28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Utility Tools',
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: AppSize.sp24,
                   color: Colors.white,
                 ),
              ),
              SizedBox(height: AppSize.h6),
              Text(
                'Professional converters at your fingertips',
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: AppSize.sp13,
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
