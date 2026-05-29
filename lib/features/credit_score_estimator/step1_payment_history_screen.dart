import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import 'provider/credit_score_ad_provider.dart';
import 'provider/credit_score_estimator_provider.dart';
import 'widgets/credit_score_layout.dart';
import 'widgets/credit_score_option_tile.dart';

class Step1PaymentHistoryScreen extends StatefulWidget {
  const Step1PaymentHistoryScreen({super.key});

  @override
  State<Step1PaymentHistoryScreen> createState() => _Step1PaymentHistoryScreenState();
}

class _Step1PaymentHistoryScreenState extends State<Step1PaymentHistoryScreen> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'credit_score_step1_screen');
    _loadOwnInline();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreditScoreAdProvider>().preloadAfterStep(0);
    });
  }

  void _loadOwnInline() {
    final data = CreditScoreAdProvider.nativeForStep(0);
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  void _next() {
    final provider = context.read<CreditScoreEstimatorProvider>();
    if (provider.paymentHistory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.creditScoreStep1Validation)),
      );
      return;
    }
    context.read<CreditScoreAdProvider>().next(context, AppRoutes.creditScoreStep2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final adProvider = context.watch<CreditScoreAdProvider>();
    final options = [
      (PaymentHistory.never, l10n.creditScoreStep1Option1Label, l10n.creditScoreStep1Option1Subtitle),
      (PaymentHistory.moreThan5Years, l10n.creditScoreStep1Option2Label, l10n.creditScoreStep1Option2Subtitle),
      (PaymentHistory.twoToFiveYears, l10n.creditScoreStep1Option3Label, l10n.creditScoreStep1Option3Subtitle),
      (PaymentHistory.oneToTwoYears, l10n.creditScoreStep1Option4Label, l10n.creditScoreStep1Option4Subtitle),
      (PaymentHistory.withinLastYear, l10n.creditScoreStep1Option5Label, l10n.creditScoreStep1Option5Subtitle),
    ];

    return CreditScoreLayout(
      stepIndex: 0,
      title: l10n.creditScoreStep1Title,
      subtitle: l10n.creditScoreStep1Question,
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: _inlineAd),
      onNextPressed: _next,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w20, vertical: AppSize.h4),
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
        itemBuilder: (_, i) {
          final (value, label, subtitle) = options[i];
          final selected = provider.paymentHistory == value;
          return CreditScoreOptionTile(
            label: label,
            subtitle: subtitle,
            selected: selected,
            onTap: () => context.read<CreditScoreEstimatorProvider>().setPaymentHistory(value),
          ).animate().fadeIn(delay: (i * 60).ms, duration: 350.ms).slideX(
                begin: 0.1,
                end: 0,
                delay: (i * 60).ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}
