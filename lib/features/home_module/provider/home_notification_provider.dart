import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../notification_service/local_notifications_helper.dart';

/// Schedules 10 reminder notifications per day for [_daysAhead] days when the
/// user lands on Home, cycling through [_reminderMessages] so each slot gets
/// distinct copy. Scheduling fires automatically on construction.
class HomeNotificationProvider with ChangeNotifier {
  HomeNotificationProvider() {
    unawaited(start());
  }

  /// Base id used for reminder slots.
  /// Each slot uses `_reminderBaseId + day * _dailySlots.length + slot`.
  static const int _reminderBaseId = 8001;

  /// Number of days ahead to pre-schedule daily reminders for.
  static const int _daysAhead = 7;

  /// 10 fixed times of day at which a reminder fires.
  static const List<({int hour, int minute})> _dailySlots = [
    (hour: 9, minute: 0),
    (hour: 11, minute: 0),
    (hour: 12, minute: 30),
    (hour: 14, minute: 0),
    (hour: 15, minute: 30),
    (hour: 17, minute: 0),
    (hour: 18, minute: 0),
    (hour: 19, minute: 0),
    (hour: 20, minute: 0),
    (hour: 21, minute: 0),
  ];

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

  bool _started = false;
  bool _initialised = false;

  Future<void> _ensureInit() async {
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

  /// Safe to call repeatedly — only the first call schedules.
  ///
  /// Each slot uses a stable id so re-entering Home refreshes the batch
  /// instead of duplicating. Past slots for "today" are skipped.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _ensureInit();

    final now = DateTime.now();
    final slotsPerDay = _dailySlots.length;

    for (int day = 0; day < _daysAhead; day++) {
      for (int slot = 0; slot < slotsPerDay; slot++) {
        final time = _dailySlots[slot];
        final localFireAt = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        ).add(Duration(days: day));

        if (localFireAt.isBefore(now)) continue;

        final id = _reminderBaseId + day * slotsPerDay + slot;
        final messageIndex =
            (day * slotsPerDay + slot) % _reminderMessages.length;
        final (title, body) = _reminderMessages[messageIndex];
        final fireAt = tz.TZDateTime.from(localFireAt.toUtc(), tz.UTC);

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
  }

  /// Cancels every reminder slot scheduled by [start].
  Future<void> stop() async {
    _started = false;
    final total = _daysAhead * _dailySlots.length;
    for (int i = 0; i < total; i++) {
      await LocalNotificationHelper.flutterLocalNotificationsPlugin
          .cancel(_reminderBaseId + i);
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
