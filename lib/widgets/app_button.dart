import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';



// ── AppButton ──────────────────────────────────────────────────────────────

/// Global app button - supports both filled and outlined styles
class AppButton extends StatefulWidget {
  const AppButton({
    required this.text,
    super.key,
    this.isLoading = false,
    this.isDisabled = false,
    this.showIconOnly = false,
    this.isFillButton = true,
    this.isOutlined = false,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.buttonStyle,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.visualDensity,
    this.textStyle,
    this.buttonColor,
    this.primary,
    this.horizontalPad,
    this.borderRadius,
    this.gradient,
    this.isAdjust = false,
    this.isLoginButton = false,
    this.borderColor,
    this.borderWidth,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ButtonStyle? buttonStyle;
  final VisualDensity? visualDensity;
  final TextStyle? textStyle;
  final Widget? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showIconOnly;
  final bool isFillButton;
  final bool isOutlined;
  final Color? buttonColor;
  final Color? primary;
  final Gradient? gradient;
  final double? horizontalPad;
  final double? borderRadius;
  final bool isAdjust;
  final bool isLoginButton;
  final Color? borderColor;
  final double? borderWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isProcessing = false;
  Timer? _debounceTimer;

  void _handleTap() {
    if (_isProcessing) return;
    _isProcessing = true;
    widget.onPressed?.call();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _isProcessing = false,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppSize.r34;

    return GestureDetector(
      onTap: widget.isDisabled
          ? null
          : widget.isLoading
          ? () {}
          : _handleTap,
      child: widget.isAdjust
          ? _adjustedLayout(radius)
          : _fullWidthLayout(radius),
    );
  }

  // ── Layout variants (same structure as before) ───────────────────────────

  Widget _adjustedLayout(double radius) {
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: IntrinsicWidth(
        child: _glowContainer(
          radius: radius,
          height: null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPad ?? AppSize.w12,
            vertical: AppSize.h4,
          ),
          child: widget.isLoading ? _loader() : _buildButtonContent(context),
        ),
      ),
    );
  }

  Widget _fullWidthLayout(double radius) {
    return Padding(
      padding: EdgeInsets.all(AppSize.r5),
      child: _glowContainer(
        radius: radius,
        height: AppSize.h50,
        padding: EdgeInsets.zero,
        child: widget.isLoading ? _loader() : _buildButtonContent(context),
      ),
    );
  }

  // ── Glow container (replaces old BoxDecoration container) ────────────────

  Widget _glowContainer({
    required double radius,
    required double? height,
    required EdgeInsetsGeometry padding,
    required Widget child,
  }) {
    // ── Outlined button style ──────────────────────────────────────────────
    if (widget.isOutlined) {


      return Container(
        height: height,
        width: height != null ? double.infinity : null,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            width: widget.borderWidth ?? 1.3,
            color: Color(0xff686767),
          ),
        ),
        child: child,
      );
    }

    // ── Filled button style ────────────────────────────────────────────────
    // If a custom gradient was explicitly passed, fall back to the original
    // flat-gradient look so caller behaviour is preserved.
    if (widget.gradient == null) {
      final buttonColor = widget.backgroundColor ?? context.themeColors.primary;
      
      return Container(
        height: height,
        width: height != null ? double.infinity : null,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: buttonColor == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      );
    }

    // ── SVG glow style ───────────────────────────────────────────────────
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        // matches blur(5.2px) in SVG filter
        filter: ui.ImageFilter.blur(sigmaX: 5.2, sigmaY: 5.2),
        child: SizedBox(
          height: height,
          width: height != null ? double.infinity : null,
          child: Container(
            // keep outline border when isFillButton == false
            decoration: widget.isFillButton
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      width: 2,
                      color: context.themeColors.primary,
                    ),
                  ),
            padding: padding,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Loading indicator (unchanged) ────────────────────────────────────────

  Widget _loader() {
    final bool isWhiteButton = widget.backgroundColor == Colors.white;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSize.h2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(
              isWhiteButton ? context.themeColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Button content (unchanged) ───────────────────────────────────────────

  Widget _buildButtonContent(BuildContext context) {
    final bool isOutlineButton = widget.buttonColor != null;
    final bool isWhiteButton = widget.backgroundColor == Colors.white;
    final textColor = widget.isDisabled
        ? Colors.grey.shade400
        : (widget.foregroundColor ?? (isWhiteButton ? context.themeTextColors.textColor : Colors.white));

    final textWidget = Padding(
      padding: EdgeInsets.only(top: AppSize.h0),
      child: Text(
        widget.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            widget.textStyle ??
            context.textTheme.titleSmall?.copyWith(
               color: widget.isOutlined ? Colors.black : textColor,
              fontSize:  AppSize.sp17,
            ),
      ),
    );



    if (widget.icon != null && widget.showIconOnly) {
      return widget.icon!;
    } else if (widget.isLoginButton && widget.icon != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w14),
        child: Row(spacing: AppSize.w35, children: [widget.icon!, textWidget]),
      );
    } else if (widget.prefixIcon != null || widget.suffixIcon != null) {
      // Handle prefix and suffix icons
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // spacing: AppSize.w8,
        children: [
          if (widget.prefixIcon != null) widget.prefixIcon!,
          Flexible(child: textWidget),
          if (widget.suffixIcon != null) widget.suffixIcon!,
        ],
      );
    } else if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSize.w4,
        children: [widget.icon!, textWidget],
      );
    } else {
      return textWidget;
    }
  }

  // ── Fallback gradient (kept for custom gradient prop) ────────────────────
  Gradient get _effectiveGradient {
    if (widget.gradient != null) return widget.gradient!;
    return LinearGradient(
      colors: [
        context.themeColors.buttonColor,
        context.themeColors.borderColor2,
      ],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    );
  }
}
