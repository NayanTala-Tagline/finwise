# ADX Fallback Ad IDs — Setup Guide

A reusable, end-to-end guide for adding **automatic ADX (Google Ad Manager) fallback**
to an `ad_manager`-style ad stack. When a primary ad fails to load, the manager
retries **once** with a fallback ad unit id pulled from Remote Config. If no
fallback id is configured, it fails as normal — **no reload, no loop**.

This is exactly what we implemented in Finlora. Copy the patterns below into the
new app.

---

## 1. Goal & behavior

- Every ad format (native, banner, interstitial, app-open, rewarded) gets one
  fallback ad unit id, supplied from Remote Config per format.
- On a **load failure**, the manager swaps to the fallback id and retries once.
- On **success of the retry** → ad loads normally (callers can't tell the
  difference).
- If the fallback id is **null/empty**, or equals the primary id → it does
  **not** retry; it fails exactly as it did before.
- Retries are **one-shot** (a single fallback attempt, never an infinite loop).

### Design principle (important)

The fallback lives **inside each per-format manager**, NOT in the switchable
wrappers (`InlineAdManager` / `FullScreenAdManager`). Each manager keeps its
single `Completer<AdStatus>` and completes it only **once** with the final
outcome (loaded after primary OR fallback, or failed). Because the wrappers,
the ad-slot widget, and every call site just delegate to that completer
(`load()` → `future()` → `isLoaded`/`isFailed`), the behavior flows through the
two entry points your app uses with **zero call-site changes**.

---

## 2. Remote Config keys

Add these to the same JSON blob your other ad slots live in (e.g. the `android`
key). `null` means "no fallback for this format".

```json
"adx_native_id":       "/23195226677,22951906221/...native",
"adx_app_open_id":     "/23195226677,22951906221/...appopen",
"adx_interstitial_id": "/23195226677,22951906221/...interstitial",
"adx_rewarded_id":     "/23195226677,22951906221/...rewarded",
"adx_banner_id":       null
```

> ⚠️ **Loader caveat.** These are Google Ad Manager `/network/...` paths. They
> often will **not fill** through AdMob loader classes (`BannerAd`,
> `InterstitialAd.load`, etc.) unless your AdMob/mediation account treats them
> as compatible. This guide swaps only the **id string** (simplest). If the
> fallbacks don't fill, switch the fallback load path to the `AdManager*`
> variants (`AdManagerBannerAd`, `AdManagerInterstitialAd`,
> `AdManagerAdRequest`).

---

## 3. Step 1 — `AdData` model

Add a `fallbackAdId` field.

```dart
class AdData {
  AdData({
    required this.adId,
    required this.enabled,
    required this.adType,
    this.templateType = TemplateType.medium,
    this.height = 0,
    this.customAdViewUrl = '',
    this.customAdUrl = '',
    this.fallbackAdId = '',          // ← NEW
  });

  String adId;
  bool enabled;
  AdType adType;
  TemplateType templateType;
  double height;
  String customAdViewUrl;
  String customAdUrl;

  /// ADX (Google Ad Manager) ad unit id used as a fallback when the primary
  /// [adId] fails to load. Empty means "no fallback — do not retry".
  String fallbackAdId;             // ← NEW

  factory AdData.fromJson(Map<String, dynamic> data) => AdData(
        adId: data['ad_id'] ?? '',
        enabled: data['enabled'] ?? false,
        adType: _adTypeFromString(data['ad_type']),
        templateType: _templateTypeFromString(data['template_type']),
        height: (data['height'] ?? 0).toDouble(),
        customAdViewUrl: data['custom_ad_view_url'] ?? '',
        customAdUrl: data['custom_ad_url'] ?? '',
        fallbackAdId: data['fallback_ad_id'] ?? '',   // ← NEW
      );

  Map<String, dynamic> toJson() => {
        'ad_id': adId,
        'enabled': enabled,
        'ad_type': adType.name,
        'template_type': templateType.name,
        'height': height,
        'custom_ad_view_url': customAdViewUrl,
        'custom_ad_url': customAdUrl,
        'fallback_ad_id': fallbackAdId,               // ← NEW
      };
}
```

---

## 4. Step 2 — Remote Config service

Add the five getters, plus a helper that maps a slot's `ad_type` to the right
fallback id, and attach it inside the `AdData` builder.

```dart
// Five getters (read from the same blob as your other ad keys).
String get adxNativeId       => _get('adx_native_id', '') ?? '';
String get adxAppOpenId      => _get('adx_app_open_id', '') ?? '';
String get adxInterstitialId => _get('adx_interstitial_id', '') ?? '';
String get adxRewardedId     => _get('adx_rewarded_id', '') ?? '';
String get adxBannerId       => _get('adx_banner_id', '') ?? '';

/// Maps a slot `ad_type` string to its ADX fallback id ('' = none).
String _fallbackAdIdFor(String adType) {
  switch (adType) {
    case 'banner':
      return adxBannerId;
    case 'interstatial':            // keep your enum's exact spelling!
      return adxInterstitialId;
    case 'openApp':
      return adxAppOpenId;
    case 'rewarded':
      return adxRewardedId;
    case 'native':
    case 'custom':
    default:
      return adxNativeId;
  }
}
```

Then, where you build each `AdData` from raw JSON, add the fallback to the map:

```dart
final String adType = raw['ad_type'] ?? 'native';

final Map<String, dynamic> data = {
  'ad_id': raw['ad_id'] ?? '',
  'enabled': raw['enabled'] ?? false,
  'ad_type': adType,
  'template_type': raw['template_type'] ?? 'small',
  'height': (raw['height'] is num) ? (raw['height'] as num).toDouble() : 0.0,
  'custom_ad_view_url': raw['custom_ad_view_url'] ?? '',
  'custom_ad_url': raw['custom_ad_url'] ?? '',
  'fallback_ad_id': _fallbackAdIdFor(adType),   // ← NEW
};
```

Don't forget the empty-ad fallback map too: `'fallback_ad_id': ''`.

> ⚠️ Match the **exact enum spelling** your project uses. In Finlora the
> interstitial enum value is misspelled `interstatial` — the switch case must
> match it character-for-character.

---

## 5. Step 3 — Managers that build the ad **inside `load()`**

This covers **native, interstitial, app-open, rewarded** (anything that builds
its ad object inside `load()` using `adData.adId`). Apply the same four edits to
each.

### 5a. Add state fields

```dart
/// Primary ad id captured at construction so a manual reload can return to it.
late final String _primaryAdId = adData.adId;

/// Set once we have swapped to the fallback; guards against loops.
bool _usedFallback = false;
```

### 5b. Split `load()` into guards + `_startLoad()`

`load()` keeps the enabled/custom/`isLoaded||isLoading` guards, then delegates
to `_startLoad()`. `_startLoad()` holds the original "set loading → dispose old
ad → build ad object → `.load()`" body, and is reused by the fallback path
**without** resetting the completer or re-checking guards.

```dart
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

  await _startLoad();                 // ← was the inline body before
}

/// Builds and loads against the current adData.adId. Reused by the fallback
/// path, so it does NOT reset the completer or re-check the load guards.
Future<void> _startLoad() async {
  adStatus = AdStatus.loading;
  if (_ad != null) { _ad!.dispose(); _ad = null; }

  try {
    await SomeAd.load(
      adUnitId: adData.adId,
      // ...existing load config...
      adLoadCallback: SomeAdLoadCallback(
        onAdLoaded: (ad) { /* ...unchanged... */ },
        onAdFailedToLoad: (error) {
          listener?.onAdFailedToLoad.call(error);
          _failOrFallback();          // ← route here instead of completing failed
        },
      ),
    );
  } catch (e) {
    debugPrint("load error: $e");
    _failOrFallback();                // ← also route the catch here
  }
}
```

### 5c. Add the `_failOrFallback()` helper

```dart
/// On a load failure, retry once against the ADX fallback id if configured.
/// Reuses the same completer so callers see a single final result. If there is
/// no usable fallback, completes as failed.
void _failOrFallback() {
  if (!_usedFallback &&
      adData.fallbackAdId.isNotEmpty &&
      adData.fallbackAdId != adData.adId) {
    _usedFallback = true;
    adData.adId = adData.fallbackAdId;   // swap to ADX id
    _startLoad();                        // rebuild + load, SAME completer
    return;
  }

  adStatus = AdStatus.failed;
  if (!_completer.isCompleted) _completer.complete(AdStatus.failed);
}
```

### 5d. Reset on manual `reload()`

```dart
Future<void> reload() async {
  if (!adData.enabled) { adStatus = AdStatus.disabled; return; }
  _ad?.dispose();
  _ad = null;
  _completer = Completer<AdStatus>();
  adStatus = AdStatus.idle;
  _usedFallback = false;               // ← NEW
  adData.adId = _primaryAdId;          // ← NEW (return to primary)
  await load();
}
```

> The key correctness rule: **do not complete the completer as `failed` before
> deciding to retry.** Move the `adStatus = failed` + `_completer.complete(...)`
> out of `onAdFailedToLoad`/`catch` and into the else-branch of
> `_failOrFallback()`, so a single completer resolves exactly once.

---

## 6. Step 4 — Banner manager (special case)

A `BannerAd`'s ad unit id is **fixed at construction**, so a banner can't just
re-`load()` with a new id — it must be **rebuilt**. Refactor:

```dart
// 1. Make the ad nullable (was `late final BannerAd _ad;`).
BannerAd? _ad;

late final String _primaryAdId = adData.adId;
bool _usedFallback = false;

// 2. Empty constructor — build lazily.
BannerAdManager({required this.adData, required this.size, this.listener});

// 3. Extract construction into a builder that reads the *current* adData.adId.
BannerAd _buildAd() {
  return BannerAd(
    adUnitId: adData.adId,
    size: size,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        adStatus = AdStatus.loaded;
        if (!_completer.isCompleted) _completer.complete(AdStatus.loaded);
      },
      onAdFailedToLoad: (ad, error) {
        listener?.onAdFailedToLoad?.call(ad, error);
        _failOrFallback();              // ← route here
      },
      // ...other callbacks unchanged...
    ),
  );
}

// 4. load() / reload() build a fresh ad each time.
Future<void> load() async {
  // ...enabled / custom guards...
  adStatus = AdStatus.loading;
  await _ad?.dispose();
  _ad = _buildAd();
  await _ad!.load();
}

Future<void> reload() async {
  // ...enabled guard...
  adStatus = AdStatus.loading;
  _completer = Completer<AdStatus>();
  _usedFallback = false;
  adData.adId = _primaryAdId;
  await _ad?.dispose();
  _ad = _buildAd();
  await _ad!.load();
}

// 5. Fallback rebuilds the BannerAd with the new id.
void _failOrFallback() {
  if (!_usedFallback &&
      adData.fallbackAdId.isNotEmpty &&
      adData.fallbackAdId != adData.adId) {
    _usedFallback = true;
    adData.adId = adData.fallbackAdId;
    adStatus = AdStatus.loading;
    _ad?.dispose();
    _ad = _buildAd();
    _ad!.load();
    return;
  }
  adStatus = AdStatus.failed;
  if (!_completer.isCompleted) _completer.complete(AdStatus.failed);
}

// 6. Null-safe everywhere else.
Widget adWidget() {
  if (isFailed || _ad == null) return const SizedBox.shrink();
  return SizedBox(
    height: _adHeight,
    child: isLoaded ? AdWidget(ad: _ad!) : _buildShimmer(),
  );
}

BannerAd? get ad => _ad;
Future<void> dispose() async => _ad?.dispose();
```

---

## 7. What you do NOT touch

- The switchable wrappers (`InlineAdManager` / `FullScreenAdManager`) — they
  delegate to the per-format managers, so the fallback is transparent.
- The ad-slot widget and any feature/call-site code — they read
  `future()`/`isLoaded`/`isFailed` and keep working unchanged.

---

## 8. Verification

1. Run `flutter pub get` in the ad package and the app, then `flutter analyze` —
   expect no new errors.
2. **Fallback fires:** set a slot's `ad_id` to an invalid value while keeping
   `enabled: true` and a valid matching `adx_*` id. Run the app, open that
   screen, and confirm via logs / the rendered ad that it retries once and fills
   from the ADX id.
3. **No-loop guard:** leave a format's `adx_*` id null with a bad `ad_id`. It
   should fail and collapse with exactly **one** failed completion — no repeated
   load attempts.
4. Sanity-check one full-screen format (app-open or interstitial) so
   `future()` / `show()` still behave when the fallback path is taken.

---

## 9. Checklist

- [ ] RC: add the five `adx_*` keys to the ad JSON blob.
- [ ] `AdData`: add `fallbackAdId` (field + ctor + `fromJson` + `toJson`).
- [ ] RC service: add 5 getters + `_fallbackAdIdFor()` + attach `fallback_ad_id`
      in the `AdData` builder + empty-ad map.
- [ ] Native / Interstitial / App-open / Rewarded managers: `_primaryAdId`,
      `_usedFallback`, split `_startLoad()`, route failures to
      `_failOrFallback()`, reset in `reload()`.
- [ ] Banner manager: nullable `_ad`, `_buildAd()`, rebuild on fallback,
      null-safe `adWidget()`/`ad`/`dispose()`.
- [ ] Match your enum's exact `ad_type` spelling in the switch.
- [ ] `flutter analyze` clean; manual fallback + no-loop test pass.
