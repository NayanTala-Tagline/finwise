import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_size.dart';

/// Rounded selectable row used across loan-finder steps.
///
/// Layout: a peach circular icon container followed by the label and an
/// animated check badge on the right when [selected]. The whole pill is
/// filled with a brand peach tint when selected.
///
/// Implementation notes:
/// - Uses [AnimatedContainer] only on cheap properties (color/border) — no
///   blurred shadows — to avoid the per-frame repaint cost that caused the
///   visible lag on selection in the earlier version.
/// - Tap-press feedback via [AnimatedScale] (subtle 0.97x).
/// - Wrapped in a [RepaintBoundary] so a tap on one tile doesn't dirty the
///   paint layer of its siblings.
class LoanFinderOptionTile extends StatefulWidget {
  const LoanFinderOptionTile({
    super.key,
      this.icon,
    required this.label,
    required this.selected,
    required this.onTap, required this.subtitle,
  });

  final SvgGenImage? icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<LoanFinderOptionTile> createState() => _LoanFinderOptionTileState();
}

class _LoanFinderOptionTileState extends State<LoanFinderOptionTile>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _selectController;
  late final Animation<double> _iconBump;

  @override
  void initState() {
    super.initState();
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.selected ? 1 : 0,
    );
    // Icon scale-bump: small overshoot to 1.05x then settle at 1.0x —
    // capped low so the bumped icon stays inside the pill's rounded
    // corners (was 1.15x, which visually clipped against the pill edge).
    _iconBump = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
    ]).animate(_selectController);
  }

  @override
  void didUpdateWidget(covariant LoanFinderOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _selectController.forward(from: 0);
      } else {
        _selectController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _selectController.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    final selected = widget.selected;

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (selected ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: AppSize.h56,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.w20,
              vertical: AppSize.h6,
            ),
            decoration: BoxDecoration(
             border: Border.all(color: Color(0xffE2E8F0)),
              borderRadius: BorderRadius.circular(AppSize.r12),
                gradient: selected ? LinearGradient(colors: [context.themeColors.primary,Color(0xff153885),]) : LinearGradient(colors: [Colors.white,Color(0xffE7F1FF),])
            ),
            child: Row(
               children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        style: context.textTheme.titleSmall!.copyWith(
                          color: selected ?  textColors.secondaryTextColor : textColors.textColor,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: AppSize.sp14,
                        ),
                        child: Text(widget.label),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        style: context.textTheme.titleSmall!.copyWith(
                          color: selected ?  textColors.secondaryTextColor : textColors.descriptionColor,

                          fontSize: AppSize.sp12,
                        ),
                        child: Text(widget.subtitle),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: Tween<double>(begin: 0.4, end: 1).animate(anim),
                    child: FadeTransition(
                      opacity: anim,
                      child: RotationTransition(
                        turns: Tween<double>(begin: -0.2, end: 0)
                            .animate(anim),
                        child: child,
                      ),
                    ),
                  ),
                  child: selected
                      ? Icon(
                        Icons.check_rounded,
                        size: AppSize.sp20,
                        color: colors.whiteColor,
                      )
                      : SizedBox(
                          key: const ValueKey('empty'),
                          width: AppSize.w8,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
