import 'package:flutter/material.dart';

/// Reusable background widget for application summary cards
/// 
/// Can be used with:
/// - Solid color background
/// - Gradient background
/// - Image overlay with color blend
/// 
/// Example usage:
/// ```dart
/// AppSummaryBackground(
///   backgroundColor: Colors.blue,
///   useImage: true,
///   imagePath: 'assets/images/splash_screen.png',
///   child: YourContent(),
/// )
/// ```
class AppSummaryBackground extends StatelessWidget {
  const AppSummaryBackground({
    super.key,
    required this.child,
    this.backgroundColor,
    this.gradientColors,
    this.useImage = false,
    this.imagePath,
    this.imageOpacity = 0.3,
    this.imageBlendMode = BlendMode.hardLight,
    this.borderRadius,
  });

  /// The content to display on top of the background
  final Widget child;

  /// Single background color (used if gradientColors is null)
  final Color? backgroundColor;

  /// Gradient colors (overrides backgroundColor if provided)
  final List<Color>? gradientColors;

  /// Whether to show image overlay
  final bool useImage;

  /// Path to the image asset (required if useImage is true)
  final String? imagePath;

  /// Opacity of the image overlay (0.0 to 1.0)
  final double imageOpacity;

  /// Blend mode for the image
  final BlendMode imageBlendMode;

  /// Border radius for the container
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        children: [
          // Layer 1: Background color or gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: gradientColors == null ? backgroundColor : null,
                gradient: gradientColors != null
                    ? LinearGradient(
                        colors: gradientColors!,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
            ),
          ),
          // Layer 2: Optional image overlay
          if (useImage && imagePath != null)
            Positioned.fill(
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                color: backgroundColor?.withValues(alpha: imageOpacity),
                colorBlendMode: imageBlendMode,
                alignment: Alignment.center,
              ),
            ),
          // Layer 3: Optional gradient overlay (when using image)
          if (useImage && gradientColors != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors!
                        .map((c) => c.withValues(alpha: 0.7))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          // Layer 4: Content
          child,
        ],
      ),
    );
  }
}
