import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/utils/remote_config.dart';
import 'package:finwise/widgets/ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_appbar.dart';
import 'model/currency_item.dart';
import 'provider/currency_provider.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  late CurrencyItem _pending;
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'currency_screen');
    _pending = context.read<CurrencyProvider>().selected;
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.contactNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
          titleText: context.l10n.settingsCurrency,
          titleTextStyle: context.textTheme.bodyMedium?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w700,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.w16,
                AppSize.h16,
                AppSize.w16,
                AppSize.h8,
              ),
              child: Text(
                context.l10n.currencyListTitle,
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
                itemCount: CurrencyItem.all.length,
                itemBuilder: (context, index) {
                  final item = CurrencyItem.all[index];
                  final isSelected = item.code == _pending.code;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h10),
                    child: GestureDetector(
                      onTap: () => setState(() => _pending = item),
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
                              color: Color(0xff000000).withValues(alpha: 0.04),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Symbol badge
                            Container(
                              width: AppSize.w34,
                              height: AppSize.h34,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary.withValues(alpha: 0.1)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(
                                  AppSize.r10,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  item.symbol,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize: item.symbol.length > 2
                                            ? AppSize.sp11
                                            : AppSize.sp15,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? colors.primary
                                            : textColors.textColor,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSize.w12),
                            // Country + code
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.country,
                                    style: context.textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: AppSize.sp14,
                                          fontWeight: FontWeight.w600,
                                          color: textColors.textColor,
                                        ),
                                  ),
                                  SizedBox(height: AppSize.h2),
                                  Text(
                                    item.code,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
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
                                        border: Border.all(
                                          color: colors.primary,
                                        ),
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
                                        border: Border.all(color: Colors.black),
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
            AdSlot(ad: _inlineAd,safeAreaBottom: false,),
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
                    onPressed: () {
                      context.read<CurrencyProvider>().setCurrency(_pending);
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
