import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'local_notifications_helper.dart';

/// Schedules the "Cash loan approved!" local notification that fires 2–5
/// minutes after the user submits a loan application.
///
/// Reuses the singleton plugin instance exposed by [LocalNotificationHelper]
/// and the existing Android channel — does not modify the notification_service
/// module. Permission is handled separately by `NotificationPermissionService`.
class LoanStatusNotification {
  const LoanStatusNotification._();

  /// Stable id so a fresh submission replaces any previously-pending schedule.
  static const int _notificationId = 9001;

  static bool _initialised = false;

  static Future<void> _ensureInit() async {
    if (_initialised) return;
    tz_data.initializeTimeZones();

    // Plain plugin init (no system permission prompt — that's handled by
    // NotificationPermissionService). Safe to call multiple times.
    await LocalNotificationHelper.flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await LocalNotificationHelper.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(LocalNotificationHelper.channel);

    _initialised = true;
  }

  /// Base id used by [scheduleReminders]. Each slot uses `_reminderBaseId + i`.
  static const int _reminderBaseId = 8001;

  /// How many reminder notifications to schedule per home-screen entry.
  static const int _reminderSlots = 15;

  /// Distinct title / body pairs cycled through for each reminder slot.
  static const List<(String, String)> _reminderMessages = [
    (
      'Find the right loan today',
      'Use the Loan Finder to compare options tailored to your income.',
    ),
    (
      'Smart EMI in seconds',
      'Open the EMI calculator and plan your monthly repayments.',
    ),
    (
      'Compare two loans, choose better',
      'Side-by-side EMI, interest and total payout — only in Compare.',
    ),
    (
      'Need quick conversions?',
      'Temperature, mass, speed and length — all in the Tools tab.',
    ),
    (
      'Track your interest rate',
      'A small rate change can save you thousands. Recheck your loan today.',
    ),
    (
      'Plan your home loan',
      'Estimate the EMI for your dream home in just one tap.',
    ),
    (
      'Education loan made simple',
      'Find the best student-loan options to invest in your future.',
    ),
    (
      'Vehicle loan in minutes',
      'Compare car-loan EMIs and pick the most affordable plan.',
    ),
    (
      'Boost your business',
      'Discover business loans tailored to expand your venture.',
    ),
    (
      'Fixed deposit calculator',
      'See exactly how much your savings could grow with an FD.',
    ),
    (
      'Recurring deposit insights',
      'Plan a steady RD goal and track maturity in seconds.',
    ),
    (
      'Save more with smarter rates',
      'Open Compare to see which lender offers the lowest EMI.',
    ),
    (
      'Documents required?',
      'Get the complete loan-application checklist inside the app.',
    ),
    (
      'Tips for faster approval',
      'Read quick advice on building a strong loan application.',
    ),
    (
      'Your finances, one tap away',
      'Loans, tools and comparisons — finlora has you covered.',
    ),
  ];

  /// Schedules 15 reminder notifications with distinct titles / descriptions.
  ///
  /// Production target is one every 30 minutes; the current spacing is
  /// 1 minute for QA. Each slot uses a stable id (`_reminderBaseId + index`)
  /// so re-entering the home screen refreshes the batch instead of duplicating.
  static Future<void> scheduleReminders() async {
    await _ensureInit();

    // TESTING: 1 minute apart. Swap to `Duration(minutes: 30 * (i + 1))`
    // for the half-hourly production cadence.
    const intervalMinutes = 1;

    final now = DateTime.now();

    for (int i = 0; i < _reminderSlots; i++) {
      final id = _reminderBaseId + i;
      final fireAt = tz.TZDateTime.from(
        now.add(Duration(minutes: intervalMinutes * (i + 1))),
        tz.UTC,
      );
      final (title, body) = _reminderMessages[i % _reminderMessages.length];

      // Cancel any prior schedule under this id so re-entry refreshes.
      // await LocalNotificationHelper.flutterLocalNotificationsPlugin.cancel(id);

      try {
        await LocalNotificationHelper.flutterLocalNotificationsPlugin
            .zonedSchedule(
          id,
          title,
          body,
          fireAt,
          NotificationDetails(
            android: LocalNotificationHelper.androidNotificationDetails,
            iOS: LocalNotificationHelper.darwinNotificationDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {
        // Permission may not yet be granted — skip this slot silently.
      }
    }
  }

  /// Cancels every slot scheduled by [scheduleReminders].
  static Future<void> cancelReminders() async {
    for (int i = 0; i < _reminderSlots; i++) {
      await LocalNotificationHelper.flutterLocalNotificationsPlugin
          .cancel(_reminderBaseId + i);
    }
  }

  /// Schedules the approval notification with a random 2–5 minute delay.
  ///
  /// The user's selected loan [amount] and the current year are interpolated
  /// into the body copy.
  static Future<void> scheduleApproval({required double amount}) async {
    await _ensureInit();

    // 2–5 minutes — Random().nextInt(181) → 0..180s on top of 120s.
    final delaySeconds = 120 + Random().nextInt(181);
    // Anchor to UTC so we don't depend on `tz.local` being configured.
    final fireAt = tz.TZDateTime.from(
      DateTime.now().add(Duration(seconds: delaySeconds)),
      tz.UTC,
    );

    final year = DateTime.now().year;

    await LocalNotificationHelper.flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId,
      'Cash loan approved!',
      'Credited ${amount.toInt()} on $year, check your balance.',
      fireAt,
      NotificationDetails(
        android: LocalNotificationHelper.androidNotificationDetails,
        iOS: LocalNotificationHelper.darwinNotificationDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
