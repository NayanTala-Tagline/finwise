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

class LoanAmountScreen extends StatefulWidget {
  const LoanAmountScreen({super.key, this.inlineAd});

  /// Native preloaded by [LoanPurposeScreen]'s ad provider — owned and
  /// disposed by this screen.
  final InlineAdManager? inlineAd;

  @override
  State<LoanAmountScreen> createState() => _LoanAmountScreenState();
}

class _LoanAmountScreenState extends State<LoanAmountScreen> {
  static const List<int> _presets = [
    100000,    // ₹1L
    500000,    // ₹5L
    1000000,   // ₹10L
    2500000,   // ₹25L
    5000000,   // ₹50L
    7500000,   // ₹75L
    10000000,  // ₹1Cr.
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'loan_amount_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoanFinderAdProvider>().preloadAfterStep(1);
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
      stepIndex: 1,
      title: 'How much loan do you need?',
      subtitle: 'Choose an amount that fits your needs',
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: () {
        AnalyticsManager.instance.logEvent(
          name: 'loan_finder_next',
          parameters: {
            'step': 2,
            'loan_amount': formProvider.loanAmount.toInt(),
          },
        );
        context
            .read<LoanFinderAdProvider>()
            .next(context, AppRoutes.monthlyIncome);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: LoanFinderAmountSection(
          value: formProvider.loanAmount,
          presets: _presets,
          min: 10000,
          max: 10000000,
          onChanged: (v) =>
              context.read<LoanFinderProvider>().setLoanAmount(v),
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
