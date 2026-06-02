# Android Native Ads — Custom Template Setup (Flutter + google_mobile_ads)

A drop-in guide to render **AdMob native ads with your own Android XML UI** in a
Flutter app, the way this project does it. Hand this file to any new app and
follow it top to bottom.

It covers the part the official docs gloss over: a **custom `NativeAdFactory`**
on the Android side that inflates your own `NativeAdView` layout, plus the
**AdChoices "info" icon gotcha** that silently hides the icon.

> Scope: **Android only.** iOS native ads use the SDK's built-in
> `NativeTemplateStyle` renderer (no custom factory). See [§8](#8-ios-note).

---

## 0. How it works (the flow)

```
Dart                              Android (native)
────                              ────────────────
NativeAd(                         MainActivity.configureFlutterEngine()
  factoryId: "small"/"medium",      └─ registerNativeAdFactory("small",  …)
  nativeTemplateStyle: null  ──►     └─ registerNativeAdFactory("medium", …)
)                                          │
   │  plugin loads the ad                  ▼
   └──────────────────────────►  NativeTemplateFactory.createNativeAd(nativeAd)
                                   ├─ LayoutInflater → native_ad_small.xml
                                   ├─ bind headline / body / cta / icon / media
                                   ├─ adView.setNativeAd(nativeAd)
                                   └─ returns NativeAdView  ──► shown in AdWidget
```

Key idea: the **`factoryId` string** the Dart side passes must **exactly match**
the id you register in `MainActivity`. We use `"small"` and `"medium"`.

On Android we deliberately set **`nativeTemplateStyle: null`** so the plugin
routes to our factory. (When `nativeTemplateStyle` is non-null the plugin renders
its own built-in template and never calls the factory.)

---

## 1. Dependencies

`pubspec.yaml`:

```yaml
dependencies:
  google_mobile_ads: ^7.0.0   # this guide verified against 7.0.0
```

`android/app/build.gradle` — make sure `minSdkVersion >= 21` (required for
`google_mobile_ads` and for view elevation/Z-ordering).

Add your AdMob App ID to `android/app/src/main/AndroidManifest.xml` inside
`<application>`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

---

## 2. Register the factories — `MainActivity.kt`

> Replace the `package` line with **your app's** package (must match the
> `applicationId` in `build.gradle`). The factory class must live in the same
> package, or be imported.

```kotlin
package com.your.app.package

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // factoryId values ("small" / "medium") MUST match what the Dart side
        // passes to NativeAd(factoryId: ...).
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
```

---

## 3. The factory — `NativeTemplateFactory.kt`

One factory class drives **both** templates; only the layout resource differs.
Subviews missing from a layout (e.g. small has no `MediaView`) are skipped via
the null-safe `findViewById?.let { }`.

```kotlin
package com.your.app.package

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

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

        // CTA: NativeAdView accepts any View, so we use a styled TextView with
        // a gradient drawable instead of a stock Button.
        adView.findViewById<TextView>(R.id.ad_call_to_action)?.let {
            it.visibility = if (nativeAd.callToAction.isNullOrEmpty()) View.GONE else View.VISIBLE
            it.text = nativeAd.callToAction
            adView.callToActionView = it
        }

        adView.findViewById<ImageView>(R.id.ad_app_icon)?.let {
            val d = nativeAd.icon?.drawable
            it.visibility = if (d == null) View.GONE else View.VISIBLE
            it.setImageDrawable(d)
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

        // ⚠️ AdChoices: do NOT call adView.setAdChoicesView(...). That is a
        // limited-access API, ignored for normal accounts, and assigning it
        // suppresses the icon entirely. The SDK auto-overlays the AdChoices
        // "info" icon as the LAST child of the NativeAdView. Your only job is
        // to not paint over it — see the AdChoices section below.
        adView.setNativeAd(nativeAd)
        return adView
    }
}
```

> **Required view IDs** your layouts must expose: `ad_headline`, `ad_body`,
> `ad_call_to_action`, `ad_app_icon`, `ad_advertiser`, `ad_media`. Any you omit
> are simply not bound.

---

## 4. ⚠️ The AdChoices "info" icon gotcha (read this)

This is the part that costs hours. Symptom: **the AdChoices info icon never
appears**, on test ads *and* real ads.

**Why:** the SDK injects the AdChoices icon as the **last child** of your
`NativeAdView` (a `FrameLayout`). But in a `FrameLayout`, **view elevation wins
the draw order regardless of child position**. If your content card has
`android:elevation="3dp"` and the auto-injected icon has elevation `0dp`, the
card paints *on top of* the icon and hides it.

**Fix — two rules:**

1. **Do NOT** call `adView.setAdChoicesView(...)` (limited-access API → ignored
   → no icon). Let the SDK auto-place it.
2. **Do NOT** put `android:elevation` (or `translationZ`) on the content
   card/container inside the `NativeAdView`. Any elevation > 0 re-hides the icon.

If you need a drop shadow, bake it into the background **drawable** (a
`layer-list` with an offset shadow layer) instead of using `elevation`.

You can optionally control the corner from Dart via
`NativeAdOptions(adChoicesPlacement: ...)` (default is top-right) — but you do
**not** need an `AdChoicesView` in the layout.

> Note: the icon still won't render on Google's **test** native creative or on
> some **mediated** fills (Unity/AppLovin/Meta render attribution their own
> way). Verify on a **real Google-direct production fill**.

---

## 5. Layouts

The root **must** be `com.google.android.gms.ads.nativead.NativeAdView`.
No `elevation` anywhere on the inner card (see [§4](#4--the-adchoices-info-icon-gotcha-read-this)).

### `res/layout/native_ad_small.xml` — horizontal pill (icon · text · CTA)

```xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.gms.ads.nativead.NativeAdView
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@drawable/native_ad_card_bg"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:paddingStart="14dp" android:paddingTop="8dp"
        android:paddingEnd="14dp" android:paddingBottom="8dp">

        <FrameLayout
            android:layout_width="60dp" android:layout_height="60dp"
            android:layout_marginEnd="14dp">
            <ImageView
                android:id="@+id/ad_app_icon"
                android:layout_width="52dp" android:layout_height="52dp"
                android:layout_gravity="center"
                android:adjustViewBounds="true" android:scaleType="centerCrop" />
        </FrameLayout>

        <LinearLayout
            android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:orientation="vertical">

            <LinearLayout
                android:layout_width="match_parent" android:layout_height="wrap_content"
                android:gravity="center_vertical" android:orientation="horizontal">

                <TextView
                    android:id="@+id/ad_attribution"
                    android:layout_width="wrap_content" android:layout_height="wrap_content"
                    android:layout_marginEnd="6dp"
                    android:background="@drawable/native_ad_attribution_bg"
                    android:paddingStart="6dp" android:paddingTop="1dp"
                    android:paddingEnd="6dp" android:paddingBottom="1dp"
                    android:text="Ad" android:textColor="#F95024"
                    android:textSize="10sp" android:textStyle="bold" />

                <TextView
                    android:id="@+id/ad_headline"
                    android:layout_width="0dp" android:layout_height="wrap_content"
                    android:layout_weight="1" android:ellipsize="end" android:maxLines="1"
                    android:textColor="#1A1A1A" android:textSize="15sp" android:textStyle="bold" />
            </LinearLayout>

            <TextView
                android:id="@+id/ad_body"
                android:layout_width="match_parent" android:layout_height="wrap_content"
                android:layout_marginTop="3dp" android:ellipsize="end" android:maxLines="2"
                android:textColor="#807F7E" android:textSize="13sp" />
        </LinearLayout>

        <TextView
            android:id="@+id/ad_call_to_action"
            android:layout_width="wrap_content" android:layout_height="48dp"
            android:layout_marginStart="10dp"
            android:background="@drawable/native_ad_cta_bg"
            android:gravity="center" android:maxLines="1" android:minWidth="96dp"
            android:paddingStart="18dp" android:paddingEnd="18dp"
            android:textAllCaps="false" android:textColor="#000000"
            android:textSize="13sp" android:textStyle="bold" />
    </LinearLayout>
    <!-- NO elevation on the card above → SDK's auto AdChoices icon stays visible. -->
</com.google.android.gms.ads.nativead.NativeAdView>
```

### `res/layout/native_ad_medium.xml` — stacked card with media

```xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.gms.ads.nativead.NativeAdView
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginStart="12dp" android:layout_marginEnd="12dp">

    <LinearLayout
        android:layout_width="match_parent" android:layout_height="wrap_content"
        android:background="@drawable/native_ad_card_bg_medium"
        android:orientation="vertical"
        android:paddingStart="14dp" android:paddingTop="14dp"
        android:paddingEnd="14dp" android:paddingBottom="14dp">

        <LinearLayout
            android:layout_width="match_parent" android:layout_height="wrap_content"
            android:gravity="center_vertical" android:orientation="horizontal">

            <FrameLayout
                android:layout_width="44dp" android:layout_height="44dp"
                android:layout_marginEnd="10dp">
                <ImageView
                    android:id="@+id/ad_app_icon"
                    android:layout_width="32dp" android:layout_height="32dp"
                    android:layout_gravity="center"
                    android:adjustViewBounds="true" android:scaleType="centerCrop" />
            </FrameLayout>

            <LinearLayout
                android:layout_width="0dp" android:layout_height="wrap_content"
                android:layout_weight="1" android:orientation="vertical">

                <LinearLayout
                    android:layout_width="match_parent" android:layout_height="wrap_content"
                    android:gravity="center_vertical" android:orientation="horizontal">

                    <TextView
                        android:id="@+id/ad_attribution"
                        android:layout_width="wrap_content" android:layout_height="wrap_content"
                        android:layout_marginEnd="6dp"
                        android:background="@drawable/native_ad_attribution_bg"
                        android:paddingStart="6dp" android:paddingTop="1dp"
                        android:paddingEnd="6dp" android:paddingBottom="1dp"
                        android:text="Ad" android:textColor="#F95024"
                        android:textSize="10sp" android:textStyle="bold" />

                    <TextView
                        android:id="@+id/ad_headline"
                        android:layout_width="0dp" android:layout_height="wrap_content"
                        android:layout_weight="1" android:ellipsize="end" android:maxLines="1"
                        android:textColor="#1A1A1A" android:textSize="15sp" android:textStyle="bold" />
                </LinearLayout>

                <TextView
                    android:id="@+id/ad_advertiser"
                    android:layout_width="match_parent" android:layout_height="wrap_content"
                    android:layout_marginTop="2dp" android:ellipsize="end" android:maxLines="1"
                    android:textColor="#9E9E9E" android:textSize="11sp" />
            </LinearLayout>
        </LinearLayout>

        <TextView
            android:id="@+id/ad_body"
            android:layout_width="match_parent" android:layout_height="wrap_content"
            android:layout_marginTop="10dp" android:ellipsize="end" android:maxLines="2"
            android:textColor="#807F7E" android:textSize="12sp" />

        <com.google.android.gms.ads.nativead.MediaView
            android:id="@+id/ad_media"
            android:layout_width="match_parent" android:layout_height="140dp"
            android:layout_marginTop="10dp" />

        <TextView
            android:id="@+id/ad_call_to_action"
            android:layout_width="match_parent" android:layout_height="48dp"
            android:layout_marginTop="12dp"
            android:background="@drawable/native_ad_cta_bg"
            android:gravity="center" android:maxLines="1"
            android:paddingStart="14dp" android:paddingEnd="14dp"
            android:textAllCaps="false" android:textColor="#000000"
            android:textSize="13sp" android:textStyle="bold" />
    </LinearLayout>
    <!-- NO elevation on the card above → SDK's auto AdChoices icon stays visible. -->
</com.google.android.gms.ads.nativead.NativeAdView>
```

---

## 6. Drawables (`res/drawable/`)

Recolor the hex values to your brand. These use `0dp` corners to sit flush; bump
the radius if you want rounded cards.

```xml
<!-- native_ad_card_bg.xml — small card background -->
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#FFFFFF" />
    <corners android:radius="0dp" />
    <stroke android:width="1dp" android:color="#1FFF8F4A" />
</shape>
```

```xml
<!-- native_ad_card_bg_medium.xml — medium card (matches page bg so it blends) -->
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#EDEDED" />
    <corners android:radius="0dp" />
    <stroke android:width="1dp" android:color="#1FFF8F4A" />
</shape>
```

```xml
<!-- native_ad_cta_bg.xml — gradient CTA button -->
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <corners android:radius="34dp" />
    <gradient android:angle="270" android:startColor="#1AED5237"
        android:endColor="#33F6AC88" android:type="linear" />
    <stroke android:width="2dp" android:color="#8CED5237" />
</shape>
```

```xml
<!-- native_ad_attribution_bg.xml — the "Ad" badge pill -->
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#FBD7B7" />
    <corners android:radius="4dp" />
</shape>
```

> Want a shadow without breaking AdChoices? Replace the `<shape>` card bg with a
> `<layer-list>` whose bottom layer is a translucent, offset shape — **never** use
> `android:elevation`.

---

## 7. Dart side

Load a `NativeAd` with the matching `factoryId`, and on Android pass
`nativeTemplateStyle: null` so the plugin uses your factory. The
`factoryId`/template name comes from your config (e.g. Remote Config field
`template_type` = `"small"` | `"medium"`).

```dart
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

NativeAd buildNativeAd({
  required String adUnitId,
  required String templateName, // "small" | "medium"
}) {
  final useAndroidFactory = Platform.isAndroid;
  return NativeAd(
    adUnitId: adUnitId,
    factoryId: templateName,                 // MUST match MainActivity ids
    request: const AdRequest(),
    // Android → null so the custom Kotlin factory is invoked.
    // iOS → built-in template renderer (no factory registered).
    nativeTemplateStyle: useAndroidFactory
        ? null
        : NativeTemplateStyle(
            templateType: templateName == 'medium'
                ? TemplateType.medium
                : TemplateType.small,
          ),
    listener: NativeAdListener(
      onAdLoaded: (ad) {/* mark loaded */},
      onAdFailedToLoad: (ad, err) { ad.dispose(); },
    ),
  )..load();
}
```

Display it (size the platform view; a custom factory's `wrap_content` doesn't
always propagate to Flutter, so give a content-accurate fallback height):

```dart
SizedBox(
  height: isMedium ? 300 : 100,   // fallback; or your configured height
  child: AdWidget(ad: nativeAd),
)
```

Always `dispose()` the ad when the widget is removed.

---

## 8. iOS note

No custom factory is registered on iOS in this setup, so iOS falls back to the
SDK's built-in `NativeTemplateStyle` renderer (which already includes its own
AdChoices icon). If you want pixel-identical custom UI on iOS too, you must
implement and register an `FLTNativeAdFactory` in Swift — out of scope here.

---

## 9. Checklist

- [ ] `minSdkVersion >= 21`, AdMob App ID in `AndroidManifest.xml`.
- [ ] `MainActivity` registers factory ids that **exactly** match the Dart
      `factoryId` strings.
- [ ] `NativeTemplateFactory` package == app package (or imported).
- [ ] Layout root is `NativeAdView`; required view IDs present.
- [ ] **No `android:elevation` / `translationZ`** on the card → AdChoices visible.
- [ ] **No `setAdChoicesView(...)`** call in the factory.
- [ ] Dart passes `nativeTemplateStyle: null` on Android.
- [ ] Native changes require a **full rebuild + reinstall** (`flutter run`);
      Kotlin/XML never hot-reload.
- [ ] Verify the AdChoices icon on a **real production Google fill** (not test
      ads, not mediated fills).

---

## 10. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Default template shows, not your UI | `factoryId` mismatch, or `nativeTemplateStyle` not null on Android. |
| Ad area blank / zero height | Platform view `wrap_content` didn't propagate — set a fallback `height` on the `SizedBox`. |
| **AdChoices icon missing** | Remove `android:elevation` from the card; remove any `setAdChoicesView(...)`; test on a real Google fill. |
| Factory never called | Not registered in `MainActivity`, or registered under a different id. Check the `Log.d("NativeAds", …)` line. |
| Crash `ClassCastException … NativeAdView` | Layout root isn't `com.google.android.gms.ads.nativead.NativeAdView`. |
