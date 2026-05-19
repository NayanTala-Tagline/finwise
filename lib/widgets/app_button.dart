import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

// ── Glow button painter ────────────────────────────────────────────────────
// Exactly replicates the SVG:
//   • Elliptical radial gradient via the exact gradientTransform matrix
//       matrix(0, 69.664, -452.997, -13.1548, 177, -8.72577)
//   • Center at gradient-space origin → user-space (177, -8.73) — just above top-centre
//   • Horizontal semi-axis ≈ 453 px, vertical semi-axis ≈ 70 px
//   • Stops: #FFFF37 @ 0.08, black @ 1.0
//   • BlendMode.colorDodge (mix-blend-mode: color-dodge)
//   • Inner highlight: white stroke offset (1,1) at 20 % opacity
class _GlowPainter extends CustomPainter {
  final double borderRadius;
  final bool isDisabled;

  const _GlowPainter({required this.borderRadius, this.isDisabled = false});

  // SVG gradientTransform: matrix(a, b, c, d, e, f)
  //   a=0  b=69.664  c=-452.997  d=-13.1548  e=177  f=-8.72577
  //
  // In Skia/Flutter, ui.Gradient.radial's localMatrix maps gradient→canvas.
  // Skia applies its inverse to canvas coords to get gradient coords — which
  // exactly matches SVG's gradientTransform semantics.
  //
  // 4×4 column-major layout (index = row + col*4):
  //   col 0 → [a, b, 0, 0]
  //   col 1 → [c, d, 0, 0]
  //   col 2 → [0, 0, 1, 0]
  //   col 3 → [e, f, 0, 1]
  static final Float64List _gradientMatrix = Float64List.fromList([
    0, 69.664, 0, 0, // col 0
    -452.997, -13.1548, 0, 0, // col 1
    0, 0, 1, 0, // col 2
    177, -8.72577, 0, 1, // col 3
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    // ── Elliptical radial gradient (color-dodge) ───────────────────────────
    // center = (0,0) in gradient space (cx=0, cy=0 from SVG)
    // radius = 1.0  (r=1 from SVG)
    // matrix = gradientTransform — Skia applies its inverse when sampling
    final gradientPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1.6,
        isDisabled
            ? [Colors.grey.shade600, Colors.grey.shade900]
            : [const Color(0xFF42fe40), Colors.black],
        const [0.01, 0.3],
        TileMode.clamp,
        _gradientMatrix,
      )
      ..blendMode = BlendMode.srcOver;

    canvas.drawRRect(rrect, gradientPaint);

    // ── Inner highlight shadow (white, offset 1,1, 20 %) ──────────────────
    canvas.save();
    canvas.clipRRect(rrect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
        Radius.circular(borderRadius - 0.5),
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..blendMode = BlendMode.srcOver,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.borderRadius != borderRadius || old.isDisabled != isDisabled;
}

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
    // Outlined button should be compact (not full width)
    if (widget.isOutlined) {
      return Align(
        alignment: Alignment.center,
        child: IntrinsicWidth(
          child: _glowContainer(
            radius: radius,
            height: AppSize.h42,
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPad ?? (widget.isOutlined ? AppSize.w44 : AppSize.w20),
              vertical: AppSize.h8,
            ),
            child: widget.isLoading ? _loader() : _buildButtonContent(context),
          ),
        ),
      );
    }

    // Filled button takes full width
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
      return Container(
        height: height,
        width: height != null ? double.infinity : null,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color(0xffF9D2C5),
              blurRadius:AppSize.r16,
              spreadRadius: AppSize.sp2
            )
          ],
          gradient:
              widget.gradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.themeColors.buttonColor.withValues(alpha: 0.1),
                  context.themeColors.buttonColor2.withValues(alpha: 0.2),
                ],
                stops: [0,1]
              ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            width: 2,
            color:  context.themeColors.buttonColor.withValues(alpha: 0.55),
          ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSize.h2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(context.themeColors.iconColor),
          ),
        ),
      ),
    );
  }

  // ── Button content (unchanged) ───────────────────────────────────────────

  Widget _buildButtonContent(BuildContext context) {
    final bool isOutlineButton = widget.buttonColor != null;
    final textColor = widget.isDisabled
        ? Colors.grey.shade400
        : (widget.foregroundColor ?? context.themeTextColors.textColor);

    final textWidget = Padding(
      padding: EdgeInsets.only(top: AppSize.h0),
      child: Text(
        widget.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            widget.textStyle ??
            context.textTheme.titleSmall?.copyWith(
               color: widget.isOutlined ? context.themeTextColors.descriptionColor : textColor,
              fontSize:  AppSize.sp17,
            ),
      ),
    );

    // Fixed refresh icon for outlined buttons
    if (widget.isOutlined) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSize.w10,
        children: [
         // Assets.icons.icRefresh.svg(width: AppSize.w16,height: AppSize.h16,fit: BoxFit.fill),
          textWidget,
        ],
      );
    }

    if (widget.icon != null && widget.showIconOnly) {
      return widget.icon!;
    } else if (widget.isLoginButton && widget.icon != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w14),
        child: Row(spacing: AppSize.w35, children: [widget.icon!, textWidget]),
      );
    } else if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSize.w6,
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
