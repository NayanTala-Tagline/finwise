//
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

@immutable
class ThemeColors extends ThemeExtension<ThemeColors> {
  const ThemeColors({
    required this.backgroundColor,
    required this.backgroundColor2,
    required this.primary,
    required this.secondary,
    required this.whiteColor,
    required this.borderColor,
    required this.iconColor,
    required this.cardColor,
    required this.borderColor2,
    required this.redColor,
    required this.redColor2,
    required this.buttonColor,
    required this.buttonColor2,
    required this.gradientColor,
    required this.gradientColor2,
    required this.secondary2,

  });

  final Color backgroundColor;
  final Color backgroundColor2;
  final Color primary;
  final Color secondary;
  final Color whiteColor;
  final Color borderColor;
  final Color iconColor;
  final Color cardColor;
  final Color borderColor2;
  final Color redColor;
  final Color redColor2;
  final Color buttonColor;
  final Color buttonColor2;
  final Color gradientColor;
  final Color gradientColor2;
  final Color secondary2;


  @override
  ThemeColors copyWith({
    Color? backgroundColor,
    Color? backgroundColor2,
    Color? primary,
    Color? secondary,
    Color? whiteColor,
    Color? borderColor,
    Color? iconColor,
    Color? cardColor,
    Color? borderColor2,
    Color? redColor,
    Color? redColor2,
    Color? buttonColor,
    Color? buttonColor2,
    Color? gradientColor,
    Color? gradientColor2,
    Color? purpleGradientColor,
    Color? purpleGradientColor2,
    Color? secondary2,


  }) {
    return ThemeColors(
      borderColor: borderColor ?? this.borderColor,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      iconColor: iconColor ?? this.iconColor,
      cardColor: cardColor ?? this.cardColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundColor2: backgroundColor2 ?? this.backgroundColor2,
      whiteColor: whiteColor ?? this.whiteColor,
      borderColor2: borderColor ?? this.borderColor2,
      redColor: redColor ?? this.redColor,
      redColor2: redColor2 ?? this.redColor2,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonColor2: buttonColor2 ?? this.buttonColor2,
      gradientColor: gradientColor ?? this.gradientColor,
      gradientColor2: gradientColor2 ?? this.gradientColor2,
      secondary2: secondary2 ?? this.secondary2,

    );
  }

  @override
  ThemeExtension<ThemeColors> lerp(
    covariant ThemeExtension<ThemeColors>? other,
    double t,
  ) {
    if (other is! ThemeColors) return this;
    return ThemeColors(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      backgroundColor2: Color.lerp(backgroundColor2, other.backgroundColor2, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      whiteColor: Color.lerp(whiteColor, other.whiteColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor2: Color.lerp(borderColor2, other.borderColor2, t)!,
      redColor: Color.lerp(redColor, other.redColor, t)!,
      redColor2: Color.lerp(redColor2, other.redColor2, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      buttonColor2: Color.lerp(buttonColor2, other.buttonColor2, t)!,
      gradientColor: Color.lerp(gradientColor, other.gradientColor, t)!,
      gradientColor2: Color.lerp(gradientColor2, other.gradientColor2, t)!,
      secondary2: Color.lerp(secondary2, other.secondary2, t)!,

    );
  }
}
