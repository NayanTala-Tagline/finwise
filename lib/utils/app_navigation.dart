import 'package:flutter/material.dart';

class AppNavigator {
  static Future<dynamic> push(BuildContext context, Widget screen) {
    return Navigator.of(context).push(_buildRoute(screen));
  }

  static Future<dynamic> pushReplacement(BuildContext context, Widget screen) {
    return Navigator.of(context).pushReplacement(_buildRoute(screen));
  }

  static Future<dynamic> pushAndRemoveUntil(BuildContext context, Widget screen) {
    return Navigator.of(context).pushAndRemoveUntil(_buildRoute(screen), (route) => false);
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Private helper for all route transitions
  static PageRouteBuilder _buildRoute(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Curves similar to Android's default interpolators
        final curve = Curves.easeOutCubic;

        // Incoming screen: right → center, with fade in
        final slideIn = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: curve));
        final fadeIn = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(slideIn),
          child: FadeTransition(opacity: animation.drive(fadeIn), child: child),
        );
      },
    );
  }
}
