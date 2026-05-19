import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<double>? stops;
  final AlignmentGeometry? beginAlignment;
  final AlignmentGeometry? endAlignment;
  const GradientBackground({super.key, required this.child, this.stops, this.beginAlignment, this.endAlignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffFFFFFF), Color(0xff2C5FF2).withValues(alpha: 0.7)],
          begin: beginAlignment ?? AlignmentGeometry.bottomEnd,
          end: endAlignment ?? AlignmentGeometry.topLeft,
          stops: stops ?? [0.63, 1],
        ),
      ),
      child: child,
    );
  }
}
