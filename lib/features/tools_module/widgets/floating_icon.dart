import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_size.dart';

class FloatingIcon extends StatelessWidget {
  const FloatingIcon({super.key, required this.icon, this.size});

  final SvgGenImage icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final dim = size ?? AppSize.w40;

    return Container(
      width: dim,
      height: dim,
      padding: EdgeInsets.all(AppSize.w6),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r10),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: AppSize.r12,
            offset: Offset(0, AppSize.h4),
          ),
        ],
      ),
      child: icon.svg(fit: BoxFit.contain),
    );
  }
}
