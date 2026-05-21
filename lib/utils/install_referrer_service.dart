import 'dart:async';
import 'dart:io';


import 'package:finwise/db/app_db.dart';
import 'package:finwise/di/injector.dart';
import 'package:finwise/utils/logger.dart';
import 'package:play_install_referrer/play_install_referrer.dart';

/// Resolves the Google Play install referrer exactly once per install and
/// caches the parsed result in [AppDB]. Organic users (`utm_medium=organic`)
/// skip onboarding; everyone else (paid, no referrer, iOS, fetch failure)
/// goes through the normal ads/onboarding flow.
///
/// Internal-testing tip: append `&referrer=utm_source%3Dtest%26utm_medium%3Dcpc`
/// to a Play install URL to simulate a paid (non-organic) install. Use
/// `utm_medium%3Dorganic` to simulate an organic install.
class InstallReferrerService {
  InstallReferrerService._();

  static final InstallReferrerService instance = InstallReferrerService._();

  Future<void>? _inflight;

  /// Fetches and parses the referrer the first time it is called. Subsequent
  /// calls return the same cached future (no extra platform calls, no extra
  /// disk writes). Always completes — never throws.
  Future<void> resolveOnce() {
    final db = Injector.instance<AppDB>();
    if (db.installReferrerChecked) return Future.value();
    return _inflight ??= _resolve(db);
  }

  Future<void> _resolve(AppDB db) async {
    // Plugin only supports Android — Play Store API.
    if (!Platform.isAndroid) {
      db
        ..installReferrerChecked = true
        ..isOrganicInstall = false;
      return;
    }

    try {
      final details = await PlayInstallReferrer.installReferrer;
      final raw = details.installReferrer ?? '';
      final organic = _isOrganic(raw);

      db
        ..installReferrerRaw = raw
        ..isOrganicInstall = organic
        ..installReferrerChecked = true;

      'installReferrer raw="$raw" organic=$organic'.logD;
    } catch (e) {
      // Play Services missing, sideloaded, etc. — treat as non-organic so the
      // user still flows through onboarding. Cache the failure so we don't
      // retry next launch.
      db
        ..installReferrerRaw = ''
        ..isOrganicInstall = false
        ..installReferrerChecked = true;
      '⚠️ installReferrer fetch failed: $e — defaulting to non-organic'.logD;
    }
  }

  /// Parses the URL-encoded referrer query string and returns true when
  /// `utm_medium` is `organic` (case-insensitive). An empty/missing referrer
  /// is NOT organic — Play returns empty for installs with no campaign info,
  /// and we treat those the same as paid (full onboarding flow).
  bool _isOrganic(String raw) {
    if (raw.isEmpty) return false;
    final params = Uri.splitQueryString(raw);
    final medium = params['utm_medium']?.trim().toLowerCase();
    return medium == 'organic';
  }
}
