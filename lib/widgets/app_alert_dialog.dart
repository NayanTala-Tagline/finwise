
import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';
import 'app_button.dart';

Future<void> showCommonConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
  required VoidCallback onConfirm,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: context.themeColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.themeTextColors.textColor,
            ),
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: context.themeTextColors.textColor, height: 1.4),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12, top: 8),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context.themeColors.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: context.themeColors.borderColor.withValues(alpha: 0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      cancelText,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.themeTextColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm button
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    text: confirmText,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
