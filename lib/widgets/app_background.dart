import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.75,
          colors: [
            Color(0xFF0E3A2A),
            Color(0xFF000503),
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}
