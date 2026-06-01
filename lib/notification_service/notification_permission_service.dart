import 'dart:async';

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
///
/// After the user opens device settings, the service waits for the app to
/// resume and re-checks the permission so the caller always gets the final
/// resolved state.
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
      return _showSettingsDialog(context);
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
        allowed = result.isGranted || result.isProvisional || result.isLimited;
        if (!allowed && result.isPermanentlyDenied && context.mounted) {
          allowed = await _showSettingsDialog(context);
        }
      },
    );
    return allowed;
  }

  /// Shows the "go to settings" dialog. If the user taps "Open Settings",
  /// waits for the app to return to the foreground, then re-checks permission.
  static Future<bool> _showSettingsDialog(BuildContext context) async {
    bool openedSettings = false;
    await NotificationSettingsDialog.show(
      context,
      onOpenSettings: () {
        openedSettings = true;
        openAppSettings();
      },
    );

    if (!openedSettings || !context.mounted) return false;

    // Block until the user returns from the system settings screen.
    await _waitForAppResume();
    if (!context.mounted) return false;

    final newStatus = await Permission.notification.status;
    return newStatus.isGranted ||
        newStatus.isProvisional ||
        newStatus.isLimited;
  }

  /// Completes the first time the app lifecycle state becomes [resumed].
  static Future<void> _waitForAppResume() {
    final completer = Completer<void>();
    late final _ResumeObserver observer;
    observer = _ResumeObserver(onResumed: () {
      WidgetsBinding.instance.removeObserver(observer);
      if (!completer.isCompleted) completer.complete();
    });
    WidgetsBinding.instance.addObserver(observer);
    return completer.future;
  }
}

class _ResumeObserver extends WidgetsBindingObserver {
  _ResumeObserver({required this.onResumed});
  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
