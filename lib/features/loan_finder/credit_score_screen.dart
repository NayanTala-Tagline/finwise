import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
 import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import 'provider/loan_finder_ad_provider.dart';
import 'provider/loan_finder_provider.dart';
import 'widgets/loan_finder_layout.dart';
import 'widgets/loan_finder_option_tile.dart';

class CreditScoreScreen extends StatefulWidget {
  const CreditScoreScreen({super.key, this.inlineAd});

  /// Native preloaded by the previous step's ad provider — owned and disposed
  /// by this screen.
  final InlineAdManager? inlineAd;

  @override
  State<CreditScoreScreen> createState() => _CreditScoreScreenState();
}

class _CreditScoreScreenState extends State<CreditScoreScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'credit_score_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoanFinderAdProvider>().preloadAfterStep(4);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  void _next() {
    final formProvider = context.read<LoanFinderProvider>();
    if (formProvider.creditScore == null) {
      AnalyticsManager.instance.logEvent(
        name: 'loan_finder_validation_failed',
        parameters: const {'step': 5, 'field': 'credit_score'},
      );
      'Please select your credit score range'.showErrorAlert();
      return;
    }
    AnalyticsManager.instance.logEvent(
      name: 'loan_finder_next',
      parameters: {
        'step': 5,
        'credit_score': formProvider.creditScore!.name,
      },
    );
    context
        .read<LoanFinderAdProvider>()
        .next(context, AppRoutes.existingLoans);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formProvider = context.watch<LoanFinderProvider>();
    final adProvider = context.watch<LoanFinderAdProvider>();
    final options = [
      _Option(CreditScoreRange.excellent, 'Excellent', '750+'),
      _Option(CreditScoreRange.good, 'Good',  '700-750'),
      _Option(CreditScoreRange.fair, 'Fair', '650-700'),
      _Option(CreditScoreRange.poor, 'Poor', 'Below 650' ),
      _Option(CreditScoreRange.dontKnow, 'Don\'t Know',''),
    ];
    return LoanFinderLayout(
      stepIndex: 4,
      title: 'What is your Credit Score range?',
      subtitle: 'Select the range that applies to you',
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: _next,
      child: ListView.separated(
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w4,
          vertical: AppSize.h8,
        ),
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
        itemBuilder: (context, index) {
          final option = options[index];
          return LoanFinderOptionTile(
            // icon: option.icon,
            subtitle: option.subTitle,
            label: option.label,
            selected: formProvider.creditScore == option.value,
            onTap: () {
              AnalyticsManager.instance.logEvent(
                name: 'loan_finder_option_selected',
                parameters: {'step': 5, 'credit_score': option.value.name},
              );
              context.read<LoanFinderProvider>().setCreditScore(option.value);
            },
          )
              .animate()
              .fadeIn(delay: (300 + index * 55).ms, duration: 380.ms)
              .slideX(begin: -0.12, end: 0, delay: (300 + index * 55).ms, duration: 500.ms, curve: Curves.easeOutCubic);
        },
      ),
    );
  }
}

class _Option {
  const _Option(this.value, this.label, this.subTitle,);
  final CreditScoreRange value;
  final String label;
  final String subTitle;
}
