package com.finwise.finance.calc.loanchecker

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // factoryId values ("small" / "medium") MUST match what the Dart side
        // passes to NativeAd(factoryId: ...) — see NativeAdManager (ad_manager).
        val smallOk = GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "small",
            NativeTemplateFactory(this, R.layout.native_ad_small)
        )
        val mediumOk = GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "medium",
            NativeTemplateFactory(this, R.layout.native_ad_medium)
        )
        Log.d("NativeAds", "factories registered small=$smallOk medium=$mediumOk")
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "small")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "medium")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
