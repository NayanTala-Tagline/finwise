import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';

class ToolItem {
  const ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.routeName,
    this.iconBgColor,
  });

  final String title;
  final String description;
  final SvgGenImage icon;
  final String routeName;
  final Color? iconBgColor;
}
