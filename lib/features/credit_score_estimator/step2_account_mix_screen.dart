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
import 'widgets/credit_score_counter_tile.dart';
import 'widgets/credit_score_layout.dart';

class Step2AccountMixScreen extends StatefulWidget {
  const Step2AccountMixScreen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Step2AccountMixScreen> createState() => _Step2AccountMixScreenState();
}

class _Step2AccountMixScreenState extends State<Step2AccountMixScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'credit_score_step2_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreditScoreAdProvider>().preloadAfterStep(1);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  int _countFor(CreditScoreEstimatorProvider p, String key) => switch (key) {
        'creditCards' => p.creditCards,
        'mortgages' => p.mortgages,
        'retailAccounts' => p.retailAccounts,
        'autoLoans' => p.autoLoans,
        'studentLoans' => p.studentLoans,
        'otherLoans' => p.otherLoans,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final adProvider = context.watch<CreditScoreAdProvider>();
    final items = [
      ('creditCards', l10n.creditScoreStep2CreditCards),
      ('mortgages', l10n.creditScoreStep2Mortgages),
      ('retailAccounts', l10n.creditScoreStep2RetailAccounts),
      ('autoLoans', l10n.creditScoreStep2AutoLoans),
      ('studentLoans', l10n.creditScoreStep2StudentLoans),
      ('otherLoans', l10n.creditScoreStep2OtherLoans),
    ];

    return CreditScoreLayout(
      stepIndex: 1,
      title: l10n.creditScoreStep2Title,
      subtitle: l10n.creditScoreStep2Question,
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: () => context.read<CreditScoreAdProvider>().next(context, AppRoutes.creditScoreStep3),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w30, vertical: AppSize.h4),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
        itemBuilder: (_, i) {
          final (key, label) = items[i];
          final count = _countFor(provider, key);
          return Padding(
            padding: EdgeInsets.only(bottom: AppSize.h10),
            child: CreditScoreCounterTile(
              label: label,
              count: count,
              onDecrement: () => context.read<CreditScoreEstimatorProvider>().setAccountCount(key, -1),
              onIncrement: () => context.read<CreditScoreEstimatorProvider>().setAccountCount(key, 1),
            ).animate().fadeIn(delay: (i * 50).ms, duration: 350.ms),
          );
        },
      ),
    );
  }
}
