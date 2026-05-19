import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

/// Expand and shrink animation
class ExpandedSection extends StatefulWidget {
  /// Default constructor
  const ExpandedSection({required this.child, super.key, this.onValueChange, this.expand = false});

  /// child widget
  final Widget child;

  /// expand or shrink
  final bool expand;

  /// On value change
  final void Function(double value)? onValueChange;

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection> with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
  ValueNotifier<bool> canAnimate = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    animation = CurvedAnimation(parent: expandController, curve: Curves.fastOutSlowIn);
    expandController.addListener(() {
      widget.onValueChange?.call(animation.value);
      if (expandController.status == AnimationStatus.completed) {
        canAnimate.value = true;
      }
    });
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController
      ..removeListener(() {})
      ..dispose();
    canAnimate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: canAnimate,
      builder: (context, value, child) {
        return SizeTransition(axisAlignment: 1, sizeFactor: animation, child: widget.child);
      },
    );
  }
}

class CustomExpandableTile extends StatefulWidget {
  const CustomExpandableTile({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.trailing,
    this.initiallyExpanded = false,
    this.onExpandChanged,
    this.titleStyle,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  /// Title text
  final String title;

  /// Child widget shown when expanded
  final Widget child;

  /// Optional leading icon
  final Widget? leading;

  /// Optional trailing widget (defaults to rotating arrow)
  final Widget? trailing;

  /// Start expanded or not
  final bool initiallyExpanded;

  /// Callback when expanded state changes
  final void Function(bool expanded)? onExpandChanged;

  /// Style for title text
  final TextStyle? titleStyle;

  /// Background color
  final Color? backgroundColor;

  /// Border radius
  final BorderRadius borderRadius;

  /// Padding inside tile header
  final EdgeInsets padding;

  @override
  State<CustomExpandableTile> createState() => _CustomExpandableTileState();
}

class _CustomExpandableTileState extends State<CustomExpandableTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    widget.onExpandChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.themeColors.cardColor,
        borderRadius: widget.borderRadius,
        border: Border.all(color: context.themeColors.borderColor, width: AppSize.w2),
        boxShadow: [
          /*  BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),*/
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Column(
          children: [
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: widget.padding,
                child: Row(
                  children: [
                    if (widget.leading != null) widget.leading!,
                    if (widget.leading != null) SizedBox(width: AppSize.w8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style:
                            widget.titleStyle ??
                            Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    widget.trailing ??
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 250),
                          turns: _isExpanded ? 0.5 : 0.0,
                          child: const Icon(Icons.keyboard_arrow_down),
                        ),
                  ],
                ),
              ),
            ),
            ExpandedSection(
              expand: _isExpanded,
              child: Padding(
                padding: EdgeInsets.only(left: AppSize.r16, right: AppSize.r16, bottom: AppSize.h16),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
