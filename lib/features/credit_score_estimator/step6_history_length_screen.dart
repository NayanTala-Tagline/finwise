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

class Step6HistoryLengthScreen extends StatefulWidget {
  const Step6HistoryLengthScreen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Step6HistoryLengthScreen> createState() => _Step6HistoryLengthScreenState();
}

class _Step6HistoryLengthScreenState extends State<Step6HistoryLengthScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'credit_score_step6_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreditScoreAdProvider>().preloadAfterStep(5);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  void _next() {
    final l10n = context.l10n;
    final provider = context.read<CreditScoreEstimatorProvider>();
    if (provider.creditHistoryLength == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.creditScoreStep6Validation)),
      );
      return;
    }
    final result = provider.calculate();
    context.read<CreditScoreAdProvider>().next(
      context,
      AppRoutes.creditScoreResult,
      extra: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final adProvider = context.watch<CreditScoreAdProvider>();
    final options = [
      (CreditHistoryLength.moreThan20Years, l10n.creditScoreStep6Option1Label, l10n.creditScoreStep6Option1Subtitle),
      (CreditHistoryLength.tenTo20Years, l10n.creditScoreStep6Option2Label, l10n.creditScoreStep6Option2Subtitle),
      (CreditHistoryLength.fiveTo10Years, l10n.creditScoreStep6Option3Label, l10n.creditScoreStep6Option3Subtitle),
      (CreditHistoryLength.twoToFiveYears, l10n.creditScoreStep1Option3Label, l10n.creditScoreStep6Option4Subtitle),
      (CreditHistoryLength.oneToTwoYears, l10n.creditScoreStep1Option4Label, l10n.creditScoreStep6Option5Subtitle),
      (CreditHistoryLength.lessThan1Year, l10n.creditScoreStep6Option6Label, l10n.creditScoreStep6Option6Subtitle),
    ];

    return CreditScoreLayout(
      stepIndex: 5,
      title: l10n.creditScoreStep6Title,
      subtitle: l10n.creditScoreStep6Question,
      isLastStep: true,
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: _next,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
              itemCount: options.length,
              separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
              itemBuilder: (_, i) {
                final (value, label, subtitle) = options[i];
                final selected = provider.creditHistoryLength == value;
                return CreditScoreOptionTile(
                  label: label,
                  subtitle: subtitle,
                  selected: selected,
                  onTap: () => context.read<CreditScoreEstimatorProvider>().setCreditHistoryLength(value),
                ).animate().fadeIn(delay: (i * 55).ms, duration: 350.ms).slideX(
                      begin: 0.1,
                      end: 0,
                      delay: (i * 55).ms,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(AppSize.w20, 0, AppSize.w20, AppSize.h12),
            padding: EdgeInsets.all(AppSize.r14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSize.r20),
              border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF16A34A), size: 18),
                SizedBox(width: AppSize.w8),
                Expanded(
                  child: Text(
                    l10n.creditScoreStep6Tip,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.sp11,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 380.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
