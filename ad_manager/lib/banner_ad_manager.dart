import 'dart:async';

import 'package:ad_manager/enum/ad_status.dart';
import 'package:ad_manager/enum/ad_type.dart';
import 'package:ad_manager/models/ad_data.dart';
import 'package:ad_manager/utils/anaytics_manager.dart';
import 'package:ad_manager/utils/revenue_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BannerAdManager {
  final AdData adData;
  final AdSize size;
  final BannerAdListener? listener;
  BannerAd? _ad;
  bool get isLoaded => adStatus == AdStatus.loaded;
  bool get isLoading => adStatus == AdStatus.loading;
  bool get isFailed => adStatus == AdStatus.failed;
  AdStatus adStatus = AdStatus.idle;
  Completer<AdStatus> _completer = Completer<AdStatus>();

  /// Primary ad id captured at construction so a manual reload can return to it.
  late final String _primaryAdId = adData.adId;

  /// Set once we have swapped to the fallback; guards against loops.
  bool _usedFallback = false;

  double get _adHeight => adData.height > 0 ? adData.height : size.height.toDouble();

  BannerAdManager({required this.adData, required this.size, this.listener});

  /// Builds a BannerAd against the *current* adData.adId. A BannerAd's ad unit
  /// id is fixed at construction, so the fallback path rebuilds via this.
  BannerAd _buildAd() {
    return BannerAd(
      adUnitId: adData.adId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          listener?.onAdLoaded?.call(ad);
          try {
            adStatus = AdStatus.loaded;
            if (!_completer.isCompleted) _completer.complete(AdStatus.loaded);
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        onAdFailedToLoad: (ad, error) {
          listener?.onAdFailedToLoad?.call(ad, error);
          _failOrFallback();
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          listener?.onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
          RevenueHelper.sendAdImpressionRevenueToFirebase(
            valueMicros: valueMicros,
            currencyCode: currencyCode,
            precision: precision,
            adUnitId: adData.adId,
          );
        },
        onAdOpened: (ad) {
          listener?.onAdOpened?.call(ad);
          AnalyticsManager.instance.logEvent(name: 'banner_ad_opened');
        },
        onAdClosed: (ad) {
          listener?.onAdClosed?.call(ad);
          AnalyticsManager.instance.logEvent(name: 'banner_ad_close');
        },
        onAdImpression: (ad) {
          listener?.onAdImpression?.call(ad);
          AnalyticsManager.instance.logEvent(name: 'banner_ad_impression');
        },
        onAdClicked: (ad) {
          AnalyticsManager.instance.logEvent(name: 'banner_ad_click');
        },
        onAdWillDismissScreen: listener?.onAdWillDismissScreen?.call,
      ),
    );
  }

  /// On a load failure, rebuild once against the ADX fallback id if configured.
  /// Reuses the same completer so callers see a single final result. If there
  /// is no usable fallback, completes as failed.
  void _failOrFallback() {
    if (!_usedFallback &&
        adData.fallbackAdId.isNotEmpty &&
        adData.fallbackAdId != adData.adId) {
      _usedFallback = true;
      adData.adId = adData.fallbackAdId; // swap to ADX id
      adStatus = AdStatus.loading;
      _ad?.dispose();
      _ad = _buildAd();
      _ad!.load();
      return;
    }

    adStatus = AdStatus.failed;
    if (!_completer.isCompleted) _completer.complete(AdStatus.failed);
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SizedBox(width: double.infinity, height: _adHeight),
    );
  }

  Widget adWidget() {
    if (adData.adType == AdType.custom) {
      return SizedBox(
        height: _adHeight,
        child: GestureDetector(
          onTap: () {
            launchUrlString(adData.customAdUrl);
          },
          behavior: HitTestBehavior.opaque,
          child: Image.network(
            height: _adHeight,
            width: double.maxFinite,
            adData.customAdViewUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: SizedBox(width: double.infinity, height: _adHeight),
              );
            },
          ),
        ),
      );
    }
    if (isFailed || _ad == null) return const SizedBox.shrink();

    return SizedBox(
      height: _adHeight,
      child: isLoaded ? AdWidget(ad: _ad!) : _buildShimmer(),
    );
  }

  Future<void> load() async {
    if (!adData.enabled) {
      adStatus = AdStatus.disabled;
    }

    if (adData.adType == AdType.custom) {
      adStatus = AdStatus.loaded;
      return;
    }

    if (!isLoaded && !isLoading && !adData.enabled) return;
    adStatus = AdStatus.loading;
    await _ad?.dispose();
    _ad = _buildAd();
    await _ad!.load();
  }

  Future<void> reload() async {
    if (!adData.enabled) {
      adStatus = AdStatus.disabled;
    }
    if (!isLoaded && !isLoading && !adData.enabled) return;
    adStatus = AdStatus.loading;
    _completer = Completer<AdStatus>();
    _usedFallback = false;
    adData.adId = _primaryAdId;
    await _ad?.dispose();
    _ad = _buildAd();
    await _ad!.load();
  }

  Future<AdStatus> future() => _completer.future;

  BannerAd? get ad => _ad;

  Future<void> dispose() async => _ad?.dispose();
}
