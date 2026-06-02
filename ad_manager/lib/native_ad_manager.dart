import 'dart:async';
import 'dart:io' show Platform;

import 'package:ad_manager/enum/ad_type.dart';
import 'package:ad_manager/models/ad_data.dart';
import 'package:ad_manager/utils/anaytics_manager.dart';
import 'package:ad_manager/utils/revenue_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'enum/ad_status.dart';

class NativeAdManager {
  final AdData adData;
  final String? factoryId;

  NativeAd? _ad;
  NativeAd? get ad => _ad;

  AdStatus adStatus = AdStatus.idle;

  bool get isLoaded => adStatus == AdStatus.loaded;
  bool get isLoading => adStatus == AdStatus.loading;
  bool get isFailed => adStatus == AdStatus.failed;

  Completer<AdStatus> _completer = Completer<AdStatus>();

  /// Primary ad id captured at construction so a manual reload can return to it.
  late final String _primaryAdId = adData.adId;

  /// Set once we have swapped to the fallback; guards against loops.
  bool _usedFallback = false;

  /// Optional external callbacks
  final NativeAdListener? listener;

  NativeAdManager({required this.adData, this.factoryId, this.listener});

  // -----------------------------
  // LOAD AD
  // -----------------------------
  Future<void> load() async {
    if (!adData.enabled) {
      adStatus = AdStatus.disabled;
      _completer.complete(AdStatus.disabled);
      return;
    }

    if (adData.adType == AdType.custom) {
      adStatus = AdStatus.loaded;
      _completer.complete(AdStatus.loaded);
      return;
    }

    if (isLoaded || isLoading) return;

    await _startLoad();
  }

  /// Builds and loads against the current adData.adId. Reused by the fallback
  /// path, so it does NOT reset the completer or re-check the load guards.
  Future<void> _startLoad() async {
    adStatus = AdStatus.loading;

    if (_ad != null) {
      _ad!.dispose();
      _ad = null;
    }

    // factoryId must match an id registered natively. On Android we register
    // "small"/"medium" factories (see MainActivity) and render our own themed
    // XML layout, so pass nativeTemplateStyle: null to route to the factory.
    // On iOS no factory is registered, so we fall back to the SDK's built-in
    // template renderer.
    final templateName = factoryId ?? adData.templateType.name; // "small" | "medium"

    _ad = NativeAd(
      adUnitId: adData.adId,
      factoryId: templateName,
      request: const AdRequest(),
      nativeTemplateStyle: Platform.isAndroid
          ? null
          : NativeTemplateStyle(templateType: adData.templateType),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          adStatus = AdStatus.loaded;

          listener?.onAdLoaded?.call(ad);

          if (!_completer.isCompleted) {
            _completer.complete(AdStatus.loaded);
          }
        },
        onAdFailedToLoad: (ad, error) {
          listener?.onAdFailedToLoad?.call(ad, error);

          AnalyticsManager.instance.logEvent(name: 'native_fail_to_load', parameters: {"message": error.message});

          _failOrFallback();
        },
        onAdOpened: (ad) {
          listener?.onAdOpened?.call(ad);
          AnalyticsManager.instance.logEvent(name: 'native_ad_opened');
        },
        onAdClosed: (ad) {
          listener?.onAdClosed?.call(ad);
          AnalyticsManager.instance.logEvent(name: 'native_ad_closed');
        },
        onAdImpression: (ad) {
          listener?.onAdImpression?.call(ad);
          AnalyticsManager.instance.logEvent(name: 'native_ad_impression');
        },
        onAdClicked: (ad) {
          listener?.onAdClicked?.call(ad);
          AnalyticsManager.instance.logEvent(name: 'native_ad_click');
        },
        onPaidEvent: (ad, micros, precision, currency) {
          listener?.onPaidEvent?.call(ad, micros, precision, currency);

          RevenueHelper.sendAdImpressionRevenueToFirebase(
            valueMicros: micros,
            currencyCode: currency,
            precision: precision,
            adUnitId: adData.adId,
          );
        },
      ),
    );

    try {
      await _ad!.load();
    } catch (e) {
      debugPrint("NativeAd load error: $e");
      _failOrFallback();
    }
  }

  /// On a load failure, retry once against the ADX fallback id if configured.
  /// Reuses the same completer so callers see a single final result. If there
  /// is no usable fallback, completes as failed.
  void _failOrFallback() {
    if (!_usedFallback &&
        adData.fallbackAdId.isNotEmpty &&
        adData.fallbackAdId != adData.adId) {
      _usedFallback = true;
      adData.adId = adData.fallbackAdId; // swap to ADX id
      _startLoad(); // rebuild + load, SAME completer
      return;
    }

    adStatus = AdStatus.failed;
    if (!_completer.isCompleted) _completer.complete(AdStatus.failed);
  }

  // -----------------------------
  // RELOAD
  // -----------------------------
  Future<void> reload() async {
    if (!adData.enabled) {
      adStatus = AdStatus.disabled;
      return;
    }

    _ad?.dispose();
    _ad = null;
    _completer = Completer<AdStatus>();
    adStatus = AdStatus.idle;
    _usedFallback = false;
    adData.adId = _primaryAdId;

    await load();
  }

  // -----------------------------
  // FUTURE (resolves on load or fail)
  // -----------------------------
  Future<AdStatus> future() => _completer.future;

  /// Height for the rendered native view. When Remote Config supplies a height
  /// we honour it; otherwise we fall back per template. This matters on Android:
  /// the custom NativeAdFactory inflates a `wrap_content` layout whose intrinsic
  /// size does not always propagate to the Flutter platform view, so a null
  /// height collapses the ad to 0 (loads fine, but invisible).
  double get _effectiveHeight {
    if (adData.height > 0) return adData.height;
    final templateName = factoryId ?? adData.templateType.name;
    return templateName == TemplateType.medium.name ? 340 : 110;
  }

  // -----------------------------
  // AD WIDGET
  // -----------------------------
  Widget adWidget() {
    if (adData.adType == AdType.custom) {
      return SizedBox(
        height: adData.height > 0 ? adData.height : null,
        child: GestureDetector(
          onTap: () {
            launchUrlString(adData.customAdUrl);
          },
          behavior: HitTestBehavior.opaque,
          child: Image.network(
            width: double.maxFinite,
            height: adData.height > 0 ? adData.height : null,
            adData.customAdViewUrl,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: SizedBox(width: double.infinity, height: adData.height > 0 ? adData.height : null),
              );
            },
          ),
        ),
      );
    }

    if (!isLoaded || _ad == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _effectiveHeight,
      child: AdWidget(ad: _ad!),
    );
  }

  // -----------------------------
  // DISPOSE
  // -----------------------------
  void dispose() {
    _ad?.dispose();
    _ad = null;
    adStatus = AdStatus.idle;
  }
}
