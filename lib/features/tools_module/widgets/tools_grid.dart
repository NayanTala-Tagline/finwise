import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_router.dart';
import '../../../utils/anaytics_manager.dart';
import '../../../utils/app_size.dart';
import '../../../utils/navigation_helper.dart';
import 'tool_card.dart';
import 'tool_item.dart';

class ToolsGrid {
  const ToolsGrid._();

  static List<ToolItem> _buildTools(BuildContext context) => [
        ToolItem(
          title: context.l10n.toolsTemperatureConvert,
          description: context.l10n.toolsTemperatureConvertDesc,
          icon: Assets.temperatureIcons.icTemperatureConvert,
          routeName: AppRoutes.temperatureConvert,
          iconBgColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
        ),
        ToolItem(
          title: context.l10n.toolsMassConvert,
          description: context.l10n.toolsMassConvertDesc,
          icon: Assets.temperatureIcons.icMassConvert,
          routeName: AppRoutes.massConvert,
          iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        ),
        ToolItem(
          title: context.l10n.toolsSpeedConvert,
          description: context.l10n.toolsSpeedConvertDesc,
          icon: Assets.temperatureIcons.icSpeedConvert,
          routeName: AppRoutes.speedConvert,
          iconBgColor: const Color(0xFF06B6D4).withValues(alpha: 0.08),
        ),
        ToolItem(
          title: context.l10n.toolsLengthConvert,
          description: context.l10n.toolsLengthConvertDesc,
          icon: Assets.temperatureIcons.icLengthConvert,
          routeName: AppRoutes.lengthConvert,
          iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.08),
        ),
      ];

  static Widget build(BuildContext context) {
    final tools = _buildTools(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.w16,
        AppSize.h20,
        AppSize.w16,
        AppSize.h24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WhyUseCard(),
          SizedBox(height: AppSize.h24),
          _SectionHeading(count: tools.length),
          SizedBox(height: AppSize.h12),
          ...tools.map((tool) => Padding(
                padding: EdgeInsets.only(bottom: AppSize.h10),
                child: ToolCard(
                  item: tool,
                  iconBgColor: tool.iconBgColor,
                  onTap: () {
                    AnalyticsManager.instance.logEvent(
                      name: 'tool_tap',
                      parameters: {'tool': tool.routeName},
                    );
                    NavigationHelper().navigateWithAdCheck(context, () {
                      context.pushNamed(tool.routeName);
                    });
                  },
                ),
              )),
          SizedBox(height: AppSize.h10),
          _HowToUseCard(),
          SizedBox(height: AppSize.h16),
        ],
      ),
    );
  }
}

class _WhyUseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.2),
            blurRadius: AppSize.r8,
            offset: Offset(0, AppSize.h4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
             padding: EdgeInsets.all(AppSize.sp8),
            decoration: BoxDecoration(
              color:      context.themeColors.primary.withValues(alpha: 0.1),
             shape: BoxShape.circle,
             ),
            child: Center(
              child: Icon(
                Icons.info_outline_rounded,
                color:   context.themeColors.primary,
                size: AppSize.sp22,
              ),
            ),
          ),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.toolsWhyUseConverters,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w600,
                   ),
                ),
                SizedBox(height: AppSize.h4),
                Text(
                  context.l10n.toolsWhyConvertersDesc,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.descriptionColor,
                   ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          context.l10n.toolsConversionTools,
          style: context.textTheme.titleLarge?.copyWith(
             fontSize: AppSize.sp17,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w10,
            vertical: AppSize.h4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF9),
            borderRadius: BorderRadius.circular(AppSize.r5),
          ),
          child: Text(
            context.l10n.toolsCountBadge(count),
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2D6B),
            ),
          ),
        ),
      ],
    );
  }
}

class _HowToUseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      context.l10n.toolsHowToUseStep1,
      context.l10n.toolsHowToUseStep2,
      context.l10n.toolsHowToUseStep3,
      context.l10n.toolsHowToUseStep4,
    ];
    final colors = context.themeColors;
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.2),
            blurRadius: AppSize.r8,
            offset: Offset(0, AppSize.h4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.toolsHowToUse,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp15,
             ),
          ),
          SizedBox(height: AppSize.h14),
          ...List.generate(
            steps.length,
            (i) => Row(
              children: [
                Container(
                   padding: EdgeInsets.all(AppSize.sp10),
                  decoration: BoxDecoration(
                    color: context.themeColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle
                   ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp14,
                        color: context.themeColors.primary
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w8),
                Flexible(
                  child: Text(
                    steps[i],
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: AppSize.sp13,
                      color: context.themeTextColors.descriptionColor,
                     ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
