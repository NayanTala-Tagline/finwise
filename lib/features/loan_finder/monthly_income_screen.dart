import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../widgets/ad_slot.dart';
import 'provider/loan_finder_ad_provider.dart';
import 'provider/loan_finder_provider.dart';
import 'widgets/loan_finder_amount_section.dart';
import 'widgets/loan_finder_layout.dart';

class MonthlyIncomeScreen extends StatefulWidget {
  const MonthlyIncomeScreen({super.key, this.inlineAd});

  /// Native preloaded by the previous step's ad provider — owned and
  /// disposed by this screen.
  final InlineAdManager? inlineAd;

  @override
  State<MonthlyIncomeScreen> createState() => _MonthlyIncomeScreenState();
}

class _MonthlyIncomeScreenState extends State<MonthlyIncomeScreen> {
  static const List<int> _presets = [
    25000,   // ₹25K
    50000,   // ₹50K
    100000,  // ₹1L
    500000,  // ₹5L
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance
        .logScreenView(screenName: 'monthly_income_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoanFinderAdProvider>().preloadAfterStep(2);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<LoanFinderProvider>();
    final adProvider = context.watch<LoanFinderAdProvider>();
    return LoanFinderLayout(
      stepIndex: 2,
      title: 'What is your monthly income?',
      subtitle: 'Your gross monthly salary or income',
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: () {
        AnalyticsManager.instance.logEvent(
          name: 'loan_finder_next',
          parameters: {
            'step': 3,
            'monthly_income': formProvider.monthlyIncome.toInt(),
          },
        );
        context
            .read<LoanFinderAdProvider>()
            .next(context, AppRoutes.employmentStatus);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: LoanFinderAmountSection(
          value: formProvider.monthlyIncome,
          presets: _presets,
          min: 10000,
          max: 500000,
          onChanged: (v) =>
              context.read<LoanFinderProvider>().setMonthlyIncome(v),
          amountColor: const Color(0xFF0D9488), // Teal color for income
          amountLabel: 'Per month',
        )
            .animate()
            .fadeIn(delay: 280.ms, duration: 420.ms)
            .slideY(
              begin: 0.1,
              end: 0,
              delay: 280.ms,
              duration: 550.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}
