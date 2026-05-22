import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_size.dart';
import '../../../utils/navigation_helper.dart';

/// Loan-finder gradient header. Implements [PreferredSizeWidget] so screens can
/// drop it straight into `Scaffold.appBar`.
class LoanFinderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LoanFinderAppBar({
    super.key,
    this.titleText,
    this.onBackPress,
    this.showBack = true,
  });

  final String? titleText;
  final VoidCallback? onBackPress;
  final bool showBack;

  static final double _barHeight = AppSize.h60;

  @override
  Size get preferredSize => Size.fromHeight(_barHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      decoration: BoxDecoration(
       color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: Offset(0,1),
          blurRadius: 2
        )
      ]
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _barHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showBack)
                Positioned(
                  left: AppSize.w12,
                  child: _BackButton(onTap: onBackPress),
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 320.ms)
                    .slideX(
                      begin: -0.6,
                      end: 0,
                      delay: 120.ms,
                      duration: 480.ms,
                      curve: Curves.easeOutCubic,
                    ),
              Text(
                titleText ?? 'Find Your Perfect Loan',
                style: context.textTheme.titleLarge?.copyWith(

                   fontSize: AppSize.sp18,
                ),
              )
                  .animate()
                  .fadeIn(duration: 380.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: -0.4,
                    end: 0,
                    duration: 520.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .shimmer(
                    delay: 500.ms,
                    duration: 1200.ms,
                    color: colors.whiteColor.withValues(alpha: 0.7),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ??
          () {
            if (context.canPop()) NavigationHelper().handleBackPress(context);
          },
      child: Icon(Icons.arrow_back_ios,color: Colors.black,)
    );
  }
}
