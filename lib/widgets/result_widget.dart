import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

/// Common Result Widget for displaying conversion results
class ResultWidget extends StatelessWidget {
  const ResultWidget({
    super.key,
    this.title = 'Result',
    required this.results,
    this.titleColor,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  final String title;
  final List<ResultItem> results;
  final Color? titleColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with orange bar
        Row(
          children: [
            Container(
              width: AppSize.w4,
              height: AppSize.h26,
              decoration: BoxDecoration(color: Color(0xffF87354),borderRadius: BorderRadius.circular(AppSize.r10)),
            ),
            SizedBox(width: AppSize.w12),
            Text(
              title,
              style: context.textTheme.titleMedium!.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: AppSize.sp18
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.h16),
        // Result container
        Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(AppSize.w20),
          decoration: BoxDecoration(
            color: backgroundColor ?? context.themeColors.whiteColor,
            borderRadius: BorderRadius.circular(borderRadius ?? AppSize.r16),
            boxShadow: [
              BoxShadow(
                color: Color(0xffFF8F4A).withValues(alpha: 0.25),
                blurRadius: AppSize.r24,
                spreadRadius: AppSize.sp1,
                // offset: Offset(0, AppSize.h2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < results.length; i++) ...[
                _buildResultRow(context, results[i]),
                if (i < results.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSize.h12),
                    child: Divider(
                      color: context.themeColors.secondary,
                      thickness: 1,
                      height: 1,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(BuildContext context, ResultItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item.label,
          style: context.textTheme.titleSmall?.copyWith(
             color: context.themeTextColors.textColor,
            fontSize: AppSize.sp16,
          ),
        ),
        Text(
          item.value,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.themeTextColors.textColor,
            fontSize: AppSize.sp16,
          ),
        ),
      ],
    );
  }
}

/// Model for result items
class ResultItem {
  final String label;
  final String value;

  const ResultItem({
    required this.label,
    required this.value,
  });
}
