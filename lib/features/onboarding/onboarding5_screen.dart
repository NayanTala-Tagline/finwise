import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/ad_slot.dart';
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_layout.dart';

class Onboarding5Screen extends StatefulWidget {
  const Onboarding5Screen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Onboarding5Screen> createState() => _Onboarding5ScreenState();
}

class _Onboarding5ScreenState extends State<Onboarding5Screen> {
  String selectedCurrency = 'INR';

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'onboarding5_screen');
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  Future<void> _handleStart(OnboardingProvider provider) async {
    AnalyticsManager.instance.logEvent(
      name: 'onboarding_complete',
      parameters: {'currency': selectedCurrency},
    );
    
    // Mark onboarding as completed
    final db = Injector.instance<AppDB>();
    db.isOnboardingCompleted = true;
    
    await provider.finishOnboarding(context, AppRoutes.loanPurpose);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider()..preloadInter5(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return OnboardingLayout(
            stepIndex: 5,
            buttonText: "Let's Go",
            isLoading: provider.busy,
            onButtonPressed: () => _handleStart(provider),
            onBackPressed: () {
              AnalyticsManager.instance.logEvent(
                name: 'onboarding_back',
                parameters: const {'step': 5},
              );
              NavigationHelper().handleBackPress(context);
            },
            adSlot: AdSlot(ad: widget.inlineAd, safeAreaBottom: false),
            child: _CurrencySelectionContent(
              selectedCurrency: selectedCurrency,
              onCurrencySelected: (currency) {
                setState(() {
                  selectedCurrency = currency;
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class _CurrencySelectionContent extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencySelected;

  const _CurrencySelectionContent({
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
      child: Column(
        children: [
          SizedBox(height: AppSize.h40),
          Container(
            padding: EdgeInsets.all(AppSize.sp30),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(AppSize.r24),
            ),
            child: Assets.onboardingIcons.icCurrency.svg(),
          ),
          SizedBox(height: AppSize.h32),
          Text(
            'Select Currency',
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp30,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h12),
          Text(
            'Choose your preferred currency for\ncalculations',
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp15,
              color: context.themeTextColors.descriptionColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.h40),
          _CurrencyList(
            selectedCurrency: selectedCurrency,
            onCurrencySelected: onCurrencySelected,
          ),
          SizedBox(height: AppSize.h24),
        ],
      ),
    );
  }
}

class _CurrencyList extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencySelected;

  const _CurrencyList({
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    final currencies = [
      _Currency('INR', 'Indian Rupee', '₹'),
      _Currency('USD', 'US Dollar', '\$'),
      _Currency('EUR', 'Euro', '€'),
      _Currency('GBP', 'British Pound', '£'),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currencies.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSize.h12),
      itemBuilder: (context, index) {
        return _CurrencyCard(
          currency: currencies[index],
          isSelected: selectedCurrency == currencies[index].code,
          onTap: () => onCurrencySelected(currencies[index].code),
        );
      },
    );
  }
}

class _Currency {
  final String code;
  final String name;
  final String symbol;

  _Currency(this.code, this.name, this.symbol);
}

class _CurrencyCard extends StatelessWidget {
  final _Currency currency;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyCard({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSize.h16,
          horizontal: AppSize.w20,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [context.themeColors.primary,Color(0xff153885),]) : LinearGradient(colors: [Colors.white,Colors.white]),
          borderRadius: BorderRadius.circular(AppSize.r16),
        ),
        child: Row(
          children: [
            Container(
padding: EdgeInsets.symmetric(horizontal: AppSize.w12,vertical: AppSize.h4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppSize.r14),
              ),
              child: Text(
                currency.symbol,
                style: TextStyle(
                  fontSize: AppSize.sp24,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            SizedBox(width: AppSize.w16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.code,
                    style: TextStyle(
                      fontSize: AppSize.sp16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: AppSize.h2),
                  Text(
                    currency.name,
                    style: TextStyle(
                      fontSize: AppSize.sp14,
                      fontWeight: FontWeight.w400,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9) 
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.done,color: Colors.white,size: AppSize.sp20,)
          ],
        ),
      ),
    );
  }
}
