import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';
import '../utils/navigation_helper.dart';

/// Common application header widget that functions as a PreferredSizeWidget (AppBar).
///
/// It provides highly customizable options for title, leading/actions, and styling
/// while maintaining a consistent design language.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// appbar title
  final Widget? title;

  /// appbar title text
  final String? titleText;

  /// appbar leading
  final Widget? leading;

  /// actions
  final List<Widget>? actions;

  /// center title
  final bool centerTitle;

  /// background color of the AppBar itself
  final Color? backgroundColor;

  /// Back press callback (used if default leading icon is shown)
  final VoidCallback? onBackPress;

  ///Horizontal Padding for the content inside the bar (defaults to AppSize.w16)
  final double? horizontalPadding;

  ///Vertical Padding for the content inside the bar
  final double? verticalPadding;

  /// Leading Width, overrides the default calculated width
  final double? leadingWidth;

  /// Toggles the visibility of the leading widget (default back button or custom leading)
  final bool showLeading;

  /// Custom text style for the title
  final TextStyle? titleTextStyle;

  /// The height of the AppBar, defaults to kToolbarHeight
  final double height;

  const CommonAppBar({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.onBackPress,
    this.horizontalPadding,
    this.verticalPadding,
    this.leadingWidth,
    this.showLeading = true,
    this.titleTextStyle,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final defaultLeading = GestureDetector(
      onTap: onBackPress ?? () => NavigationHelper().handleBackPress(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w4),
        child: Icon(
          Icons.chevron_left_rounded,
          size: AppSize.sp30,
          color: context.themeTextColors.textColor,
        ),
      ),
    );

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? AppSize.w18,
          vertical: verticalPadding ?? 0.0,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          toolbarHeight: height,
          leadingWidth: AppSize.w40,
          leading: showLeading ? (leading ?? defaultLeading) : null,
          title: title ??
              Text(
                titleText ?? '',
                style: titleTextStyle ??
                    context.textTheme.titleSmall?.copyWith(
                      fontSize: AppSize.sp18,
                      fontWeight: FontWeight.w700,
                    ),
              ),
          centerTitle: true,
          actions: actions,
        ),
      ),
    );
  }
}





