package com.finwise.finance.calc.loanchecker

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * Inflates a custom [NativeAdView] layout and binds the [NativeAd]'s assets.
 *
 * One factory drives both templates; only [layoutResId] differs. Subviews
 * missing from a layout (e.g. the small template has no MediaView) are skipped
 * via the null-safe `findViewById?.let { }`.
 *
 * Do NOT call [NativeAdView.setAdChoicesView] and do NOT put elevation on the
 * card — both hide the auto-injected AdChoices icon. See native_ads_android_setup.md §4.
 */
class NativeTemplateFactory(
    private val context: Context,
    private val layoutResId: Int
) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context).inflate(layoutResId, null) as NativeAdView

        adView.findViewById<TextView>(R.id.ad_headline)?.let {
            it.text = nativeAd.headline
            adView.headlineView = it
        }

        adView.findViewById<TextView>(R.id.ad_body)?.let {
            it.visibility = if (nativeAd.body.isNullOrEmpty()) View.GONE else View.VISIBLE
            it.text = nativeAd.body
            adView.bodyView = it
        }

        // CTA is a styled TextView (NativeAdView accepts any View).
        adView.findViewById<TextView>(R.id.ad_call_to_action)?.let {
            it.visibility = if (nativeAd.callToAction.isNullOrEmpty()) View.GONE else View.VISIBLE
            it.text = nativeAd.callToAction
            adView.callToActionView = it
        }

        adView.findViewById<ImageView>(R.id.ad_app_icon)?.let {
            val drawable = nativeAd.icon?.drawable
            it.visibility = if (drawable == null) View.GONE else View.VISIBLE
            it.setImageDrawable(drawable)
            adView.iconView = it
        }

        adView.findViewById<TextView>(R.id.ad_advertiser)?.let {
            it.visibility = if (nativeAd.advertiser.isNullOrEmpty()) View.GONE else View.VISIBLE
            it.text = nativeAd.advertiser
            adView.advertiserView = it
        }

        adView.findViewById<MediaView>(R.id.ad_media)?.let {
            adView.mediaView = it
        }

        // SDK auto-overlays the AdChoices icon as the last child — do not paint over it.
        adView.setNativeAd(nativeAd)
        return adView
    }
}
