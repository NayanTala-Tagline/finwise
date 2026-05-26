import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_size.dart';
import 'floating_icon.dart';

class ToolsHeroCluster extends StatelessWidget {
  const ToolsHeroCluster({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return SizedBox(
      width: AppSize.w160,
      height: AppSize.h160,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.whiteColor.withValues(alpha: 0.55),
                    colors.whiteColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: AppSize.h8,
            right: AppSize.w8,
            child: FloatingIcon(icon: Assets.temperatureIcons.icMassConvert, size: AppSize.w48),
          ),
          Positioned(
            top: AppSize.h36,
            left: AppSize.w8,
            child: FloatingIcon(
              icon: Assets.temperatureIcons.icSpeedConvert,
              size: AppSize.w48,
            ),
          ),
          Positioned(
            bottom: AppSize.h12,
            right: AppSize.w14,
            child: FloatingIcon(
              icon: Assets.temperatureIcons.icLengthConvert,
              size: AppSize.w48,
            ),
          ),
          Positioned(
            bottom: AppSize.h28,
            left: AppSize.w28,
            child: FloatingIcon(
              icon: Assets.temperatureIcons.icTemperatureConvert,
              size: AppSize.w48,
            ),
          ),
        ],
      ),
    );
  }
}
