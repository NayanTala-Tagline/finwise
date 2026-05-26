import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

/// A fully custom draggable slider used across the app.
///
/// Renders a coloured track, a filled active portion, and a circular thumb.
/// [minLabel] / [maxLabel] are displayed below the two ends of the track.
/// [divisions] snaps the value to evenly-spaced steps when set.
class RateSlider extends StatelessWidget {
  const RateSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
    this.activeColor,
    this.divisions,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? minLabel;
  final String? maxLabel;
  final Color? activeColor;

  /// When set, snaps to [divisions] evenly-spaced steps between [min] and [max].
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? context.themeColors.primary;
    final t = max == min ? 0.0 : ((value - min) / (max - min)).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final pos = t * w;

      void emit(double localX) {
        var newT = (localX / w).clamp(0.0, 1.0);
        double raw = min + newT * (max - min);
        if (divisions != null && divisions! > 0) {
          final step = (max - min) / divisions!;
          raw = (raw / step).round() * step;
        }
        onChanged(double.parse(raw.toStringAsFixed(1)));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => emit(d.localPosition.dx),
            onPanUpdate: (d) => emit(d.localPosition.dx),
            child: SizedBox(
              height: AppSize.h24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track background
                  Positioned(
                    left: 0,
                    right: 0,
                    top: AppSize.h9,
                    child: Container(
                      height: AppSize.h6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAED),
                        borderRadius: BorderRadius.circular(AppSize.r4),
                      ),
                    ),
                  ),
                  // Active fill
                  Positioned(
                    left: 0,
                    top: AppSize.h9,
                    child: Container(
                      width: pos,
                      height: AppSize.h6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(AppSize.r4),
                      ),
                    ),
                  ),
                  // Thumb
                  Positioned(
                    left: pos - AppSize.w12,
                    top: 0,
                    child: Container(
                      width: AppSize.w24,
                      height: AppSize.h24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.40),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSize.h8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel ?? min.toStringAsFixed(1),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.themeTextColors.descriptionColor,
                  fontSize: AppSize.sp13,
                ),
              ),
              Text(
                maxLabel ?? max.toStringAsFixed(1),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.themeTextColors.descriptionColor,
                  fontSize: AppSize.sp13,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
