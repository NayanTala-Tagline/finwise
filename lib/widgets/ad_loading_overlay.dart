import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../extension/ext_context.dart';
import '../gen/assets.gen.dart';
import '../res/theme_colors.dart';
import '../utils/app_size.dart';

/// Beautiful full-screen overlay shown while an ad is being loaded.
///
/// Usage:
/// ```dart
/// AdLoadingOverlay.show(context);
/// // ...load + show your ad...
/// AdLoadingOverlay.hide();
/// ```
class AdLoadingOverlay {
  AdLoadingOverlay._();

  static final AdLoadingOverlay _instance = AdLoadingOverlay._();

  /// Singleton accessor.
  factory AdLoadingOverlay.instance() => _instance;

  static bool _isShowing = false;
  static BuildContext? _dialogContext;

  /// Whether the overlay is currently visible.
  static bool get isShowing => _isShowing;

  /// Shows the overlay. Safe to call multiple times — second call is a no-op.
  static void show(
    BuildContext context, {
    String? message,
    String? subMessage,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      useSafeArea: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return PopScope(
          canPop: false,
          child: _AdLoadingView(
            message: message ?? 'Loading ad...',
            subMessage: subMessage ?? 'Please wait a moment',
          ),
        );
      },
    ).then((_) => _isShowing = false);
  }

  /// Hides the overlay (no-op if not visible).
  static void hide() {
    if (!_isShowing) return;
    final ctx = _dialogContext;
    if (ctx != null && ctx.mounted && ctx.canPop()) {
      ctx.pop();
    }
    _dialogContext = null;
    _isShowing = false;
  }
}

class _AdLoadingView extends StatelessWidget {
  const _AdLoadingView({required this.message, required this.subMessage});

  final String message;
  final String subMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: _LoaderCard(
              colors: colors,
              message: message,
              subMessage: subMessage,
            )
                .animate()
                .fadeIn(duration: 250.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 350.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
        ),
      ],
    );
  }
}

class _LoaderCard extends StatelessWidget {
  const _LoaderCard({
    required this.colors,
    required this.message,
    required this.subMessage,
  });

  final ThemeColors colors;
  final String message;
  final String subMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w28,
        vertical: AppSize.h28,
      ),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SpinnerWithBadge(colors: colors),
          SizedBox(height: AppSize.h20),
          _AnimatedDotsLabel(
            text: message,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.themeTextColors.textColor,
              fontWeight: FontWeight.w600,
              fontSize: AppSize.sp16,
            ),
          ),
          SizedBox(height: AppSize.h6),
          Text(
            subMessage,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.themeTextColors.hintTextColor,
              fontSize: AppSize.sp12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinnerWithBadge extends StatelessWidget {
  const _SpinnerWithBadge({required this.colors});

  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final size = AppSize.w90;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colors.primary, colors.secondary],
    );

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating gradient arc.
          SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _ArcPainter(gradient: gradient, strokeWidth: 4, sweep: 4.5),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: 1200.ms, curve: Curves.linear),

          // Inner counter-rotating arc.
          SizedBox.square(
            dimension: size - 22,
            child: CustomPaint(
              painter: _ArcPainter(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    colors.secondary.withValues(alpha: 0.85),
                    colors.primary.withValues(alpha: 0.4),
                  ],
                ),
                strokeWidth: 3,
                sweep: 3,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .rotate(
                begin: 0,
                end: -1,
                duration: 1600.ms,
                curve: Curves.linear,
              ),

          // Center badge.
          Container(
            width: size - 44,
            height: size - 44,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            // child: Center(
            //   child: Assets.splash.splashLogo.image(
            //     width: size - 60,
            //     height: size - 60,
            //     fit: BoxFit.contain,
            //   ),
            // ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.92,
                end: 1.05,
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

/// Paints a gradient stroked arc — used for the rotating spinner rings.
class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.sweep,
  });

  final Gradient gradient;
  final double strokeWidth;

  /// Sweep angle in radians.
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect.deflate(strokeWidth / 2), -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.gradient != gradient ||
      old.strokeWidth != strokeWidth ||
      old.sweep != sweep;
}

/// Renders [text] followed by three dots that animate in/out sequentially.
class _AnimatedDotsLabel extends StatefulWidget {
  const _AnimatedDotsLabel({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<_AnimatedDotsLabel> createState() => _AnimatedDotsLabelState();
}

class _AnimatedDotsLabelState extends State<_AnimatedDotsLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.text.endsWith('...')
        ? widget.text.substring(0, widget.text.length - 3)
        : widget.text;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final count = ((_ctrl.value * 4).floor() % 4);
        final dots = '.' * count;
        return Text(
          '$base$dots',
          style: widget.style,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
