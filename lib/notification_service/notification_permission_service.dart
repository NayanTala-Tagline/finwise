import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/notification_permission_dialog.dart';
import 'widgets/notification_settings_dialog.dart';

/// Orchestrates the notification-permission flow:
///
/// 1. If already granted → nothing to do.
/// 2. If permanently denied → show the settings-redirect dialog.
/// 3. Otherwise → show the explainer dialog. On "Allow" we trigger the
///    system request; if the user then permanently denies, fall back to (2).
class NotificationPermissionService {
  const NotificationPermissionService._();

  /// Ensures notification permission is granted. Shows the appropriate dialog
  /// when it's not. Returns `true` if granted (now or already), else `false`.
  static Future<bool> ensurePermission(BuildContext context) async {
    final status = await Permission.notification.status;
    if (!context.mounted) return false;

    if (status.isGranted || status.isProvisional || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(context);
      return false;
    }

    return _showRequestDialog(context);
  }

  static Future<bool> _showRequestDialog(BuildContext context) async {
    bool allowed = false;
    await NotificationPermissionDialog.show(
      context,
      onAllow: () async {
        if (!context.mounted) return;
        final result = await Permission.notification.request();
        allowed = result.isGranted;
        if (!allowed && result.isPermanentlyDenied && context.mounted) {
          await _showSettingsDialog(context);
        }
      },
    );
    return allowed;
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    await NotificationSettingsDialog.show(
      context,
      onOpenSettings: () => openAppSettings(),
    );
  }
}
