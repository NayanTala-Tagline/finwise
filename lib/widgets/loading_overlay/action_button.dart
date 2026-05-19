import 'dart:async';
import 'package:flutter/material.dart';

import '../../extension/ext_context.dart';
import '../../utils/app_size.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  @override
  State<ActionButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<ActionButton> {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w10,vertical: AppSize.h5),
        height: AppSize.h30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECAFF), Color(0xFF1C6599)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Text(
          widget.text,
          style:  context.textTheme.bodyMedium?.copyWith(fontSize: AppSize.sp14)
        ),
      ),
    );
  }
}
