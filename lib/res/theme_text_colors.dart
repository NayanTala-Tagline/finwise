//
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Theme extension for text colors
@immutable
class ThemeTextColors extends ThemeExtension<ThemeTextColors> {
  /// constructor
  const ThemeTextColors({
    required this.textColor,
    required this.textBlackColor,
    required this.hintTextColor,
    required this.descriptionColor,
    required this.pastalYellow,
    required this.primaryTextColor,
    required this.secondaryTextColor
  });

  final Color textColor;
  final Color textBlackColor;
  final Color hintTextColor;
  final Color descriptionColor;
  final Color pastalYellow;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  @override
  ThemeExtension<ThemeTextColors> copyWith({
    Color? textBlackColor,
    Color? emailHintColor,
    Color? descriptionColor,
    Color? pastalRed,
    Color? pastalYellow,
    Color? filterBgColor,
    Color? textPrimaryColor,
    Color? errorColor,
    Color? ffB0B0B0,
    Color? textFiledFillColor,
    Color? pastalGreenLight,
    Color? primaryTextColor,
    Color? secondaryTextColor,
  }) {
    return ThemeTextColors(
      textColor: textBlackColor ?? textColor,
      hintTextColor: emailHintColor ?? hintTextColor,
      descriptionColor: descriptionColor ?? this.descriptionColor,
      pastalYellow: pastalYellow ?? this.pastalYellow,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      textBlackColor: textBlackColor ?? this.textBlackColor,
    );
  }

  @override
  ThemeExtension<ThemeTextColors> lerp(covariant ThemeExtension<ThemeTextColors>? other, double t) {
    if (other is! ThemeTextColors) {
      return this;
    }
    return ThemeTextColors(
      textColor: Color.lerp(textColor, other.textColor, t)!,
      hintTextColor: Color.lerp(hintTextColor, other.hintTextColor, t)!,
      descriptionColor: Color.lerp(descriptionColor, other.descriptionColor, t)!,
      pastalYellow: Color.lerp(pastalYellow, other.pastalYellow, t)!,
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
      secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
      textBlackColor: Color.lerp(textBlackColor, other.textBlackColor, t)!,
    );
  }
}
