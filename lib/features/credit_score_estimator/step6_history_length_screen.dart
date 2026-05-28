import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
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
  static const _options = [
    (CreditHistoryLength.moreThan20Years, 'More than 20 years ago', 'Extensive history'),
    (CreditHistoryLength.tenTo20Years, '10-20 years ago', 'Long history'),
    (CreditHistoryLength.fiveTo10Years, '5-10 years ago', 'Established history'),
    (CreditHistoryLength.twoToFiveYears, '2-5 years ago', 'Building history'),
    (CreditHistoryLength.oneToTwoYears, '1-2 years ago', 'Short history'),
    (CreditHistoryLength.lessThan1Year, 'Less than 1 year ago', 'New to credit'),
  ];

  @override
  void initState() {
    super.initState();
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
    final provider = context.read<CreditScoreEstimatorProvider>();
    if (provider.creditHistoryLength == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your credit history length')),
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
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final adProvider = context.watch<CreditScoreAdProvider>();

    return CreditScoreLayout(
      stepIndex: 5,
      title: 'Credit History Length',
      subtitle: 'When did you first open your oldest active credit or loan account?',
      isLastStep: true,
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: _next,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
              itemCount: _options.length,
              separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
              itemBuilder: (_, i) {
                final (value, label, subtitle) = _options[i];
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
                    'Keep your oldest accounts open even if you don\'t use them often to maintain a longer credit history.',
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
