import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
 import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import 'model/loan_finder_result.dart';
import 'provider/loan_finder_ad_provider.dart';
import 'provider/loan_finder_provider.dart';
import 'widgets/loan_finder_layout.dart';
import 'widgets/loan_finder_option_tile.dart';

class LoanUrgencyScreen extends StatefulWidget {
  const LoanUrgencyScreen({super.key, this.inlineAd});

  /// Native preloaded by [ExistingLoansScreen]'s ad provider — owned and
  /// disposed by this screen.
  final InlineAdManager? inlineAd;

  @override
  State<LoanUrgencyScreen> createState() => _LoanUrgencyScreenState();
}

class _LoanUrgencyScreenState extends State<LoanUrgencyScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'loan_urgency_screen');
    // Last step. No "next native" to preload (recommendations doesn't take one),
    // but step7Inter still needs to be loaded for the outgoing transition.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoanFinderAdProvider>().preloadAfterStep(6);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  void _next() {
    final formProvider = context.read<LoanFinderProvider>();
    if (formProvider.urgency == null) {
      AnalyticsManager.instance.logEvent(
        name: 'loan_finder_validation_failed',
        parameters: const {'step': 7, 'field': 'urgency'},
      );
      'Please select how urgently you need the loan'.showErrorAlert();
      return;
    }
    AnalyticsManager.instance.logEvent(
      name: 'loan_finder_next',
      parameters: {
        'step': 7,
        'urgency': formProvider.urgency!.name,
      },
    );
    AnalyticsManager.instance.logEvent(name: 'loan_finder_completed');
    final result = LoanFinderResult.fromProvider(formProvider);

    // Mark onboarding complete now that the user has finished the full
    // loan-finder flow. Splash reads this on next launch to skip onboarding.
    Injector.instance<AppDB>().isOnboardingCompleted = true;

    // Pass the form result as extra — overrides the (null) ad handoff.
    context.read<LoanFinderAdProvider>().next(
          context,
          AppRoutes.recommendations,
          extra: result,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formProvider = context.watch<LoanFinderProvider>();
    final adProvider = context.watch<LoanFinderAdProvider>();
    final options = [
      _Option(LoanUrgency.immediately, 'Immediately','Within a week'),
      _Option(LoanUrgency.withinWeek, 'Soon','1-2 weeks'),
      _Option(LoanUrgency.withinMonth, 'Within a month','Planning ahead'),
      _Option(LoanUrgency.flexible, 'Flexible','No Rush'),
    ];
    return LoanFinderLayout(
      stepIndex: 6,
      title: 'How Urgently do you need the loan?',
      subtitle: 'Select the timeframe',
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
            subtitle: option.subTitle,
             label: option.label,
            selected: formProvider.urgency == option.value,
            onTap: () {
              AnalyticsManager.instance.logEvent(
                name: 'loan_finder_option_selected',
                parameters: {'step': 7, 'urgency': option.value.name},
              );
              context.read<LoanFinderProvider>().setUrgency(option.value);
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
  final LoanUrgency value;
  final String label;
  final String subTitle;

}
