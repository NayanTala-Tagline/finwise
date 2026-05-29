import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_appbar.dart';
import 'provider/locale_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  InlineAdManager? _inlineAd;
  String? _selectedLanguageCode;
  int? _selectedLanguageIndex;

  final List<Map<String, String>> languages = const [
    {'name': 'English', 'code': 'en', 'symbol': '🇬🇧'},
    {'name': 'German', 'code': 'de', 'symbol': '🇩🇪'},
    {'name': 'French', 'code': 'fr', 'symbol': '🇫🇷'},
    {'name': 'Swahili', 'code': 'sw', 'symbol': '🇰🇪'},
    {'name': 'Arabic', 'code': 'ar', 'symbol': '🇸🇦'},
    {'name': 'Hindi', 'code': 'hi', 'symbol': '🇮🇳'},
    {'name': 'Malay', 'code': 'ms', 'symbol': '🇲🇾'},
    {'name': 'Filipino', 'code': 'fil', 'symbol': '🇵🇭'},
    {'name': 'Spanish', 'code': 'es', 'symbol': '🇪🇸'},
    {'name': 'Dutch', 'code': 'nl', 'symbol': '🇳🇱'},
    {'name': 'Marathi', 'code': 'mr', 'symbol': '🇮🇳'},
    {'name': 'Telugu', 'code': 'te', 'symbol': '🇮🇳'},
    {'name': 'Tamil', 'code': 'ta', 'symbol': '🇮🇳'},
    {'name': 'Bengali', 'code': 'bn', 'symbol': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'language_selection_screen',
    );
    _loadInline();
    _initializeSelectedLanguage();
  }

  void _initializeSelectedLanguage() {
    final languageProvider = context.read<LocaleProvider>();
    _selectedLanguageCode = languageProvider.getCurrentLocaleCode() ?? 'en';
    _selectedLanguageIndex = languages.indexWhere(
      (lang) => lang['code'] == _selectedLanguageCode,
    );
    if (_selectedLanguageIndex == -1) {
      _selectedLanguageCode = 'en';
      _selectedLanguageIndex = 0;
    }
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.languageNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: CommonAppBar(
          titleText: context.l10n.settingsLanguage,
          titleTextStyle: context.textTheme.bodyMedium?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w700,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h8),
              child: Text(
                context.l10n.languageListTitle,
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: AppSize.sp16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppSize.w16,
                  AppSize.h8,
                  AppSize.w16,
                  AppSize.h12,
                ),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = _selectedLanguageCode == lang['code'];

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h10),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedLanguageCode = lang['code'];
                        _selectedLanguageIndex = index;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSize.w10,
                          vertical: AppSize.h6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.02)
                              : colors.whiteColor,
                          borderRadius: BorderRadius.circular(AppSize.r12),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff000000).withValues(alpha: 0.04),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Flag badge
                            Container(
                              width: AppSize.w34,
                              height: AppSize.h34,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary.withValues(alpha: 0.1)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(AppSize.r10),
                              ),
                              child: Center(
                                child: Text(
                                  lang['symbol']!,
                                  style: TextStyle(fontSize: AppSize.sp18),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSize.w12),
                            // Language name + code
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang['name']!,
                                    style: context.textTheme.bodyLarge?.copyWith(
                                      fontSize: AppSize.sp14,
                                      fontWeight: FontWeight.w600,
                                      color: textColors.textColor,
                                    ),
                                  ),
                                  SizedBox(height: AppSize.h2),
                                  Text(
                                    lang['code']!.toUpperCase(),
                                    style: context.textTheme.bodySmall?.copyWith(
                                      fontSize: AppSize.sp12,
                                      color: textColors.descriptionColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isSelected
                                  ? Container(
                                      key: const ValueKey('selected'),
                                      padding: EdgeInsets.all(AppSize.sp3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: colors.primary),
                                      ),
                                      child: Container(
                                        width: AppSize.w10,
                                        height: AppSize.h10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colors.primary,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey('unselected'),
                                      padding: EdgeInsets.all(AppSize.sp7),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AdSlot(ad: _inlineAd, safeAreaBottom: false),
            // Save button
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26000000),
                    offset: Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.w16,
                    AppSize.h12,
                    AppSize.w16,
                    AppSize.h0,
                  ),
                  child: AppButton(
                    text: context.l10n.currencySaveButton,
                    backgroundColor: colors.primary,
                    borderRadius: AppSize.r50,
                    onPressed: () async {
                      if (_selectedLanguageCode != null && _selectedLanguageIndex != null) {
                        final languageProvider = context.read<LocaleProvider>();
                        final selectedLang = languages[_selectedLanguageIndex!];

                        AnalyticsManager.instance.logEvent(
                          name: 'language_changed',
                          parameters: {
                            'language_name': selectedLang['name'] ?? '',
                            'language_code': selectedLang['code'] ?? '',
                          },
                        );

                        await languageProvider.setLocale(
                          Locale(_selectedLanguageCode!),
                          _selectedLanguageIndex!,
                          true,
                        );
                      }

                      if (!context.mounted) return;
                      NavigationHelper().handleBackPress(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
