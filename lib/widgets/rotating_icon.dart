import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Rotating icon widget in z axis used in the home page
class RotatingIcon extends StatefulWidget {
  /// Default constructor
  const RotatingIcon({
    super.key,
    required this.icon,
    this.isRotating = true, // 👈 Added flag to control rotation
  });

  final Widget icon;
  final bool isRotating;

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon> with TickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    );

    if (widget.isRotating) {
      _startRotation();
    }
  }

  void _startRotation() {
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      _controller.forward(from: 0);
    });
  }

  void _stopRotation() {
    _timer?.cancel();
    _controller.stop();
  }

  @override
  void didUpdateWidget(covariant RotatingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If rotation state changes dynamically
    if (oldWidget.isRotating != widget.isRotating) {
      if (widget.isRotating) {
        _startRotation();
      } else {
        _stopRotation();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If rotation is disabled → show static icon
    if (!widget.isRotating) {
      return widget.icon;
    }

    return MatrixTransition(
      animation: _animation,
      child: widget.icon,
      onTransform: (double value) {
        return Matrix4.identity()
          ..setEntry(3, 2, 0.004)
          ..rotateY(pi * 8.0 * value);
      },
    );
  }
}
