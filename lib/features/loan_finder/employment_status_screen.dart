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

class EmploymentStatusScreen extends StatefulWidget {
  const EmploymentStatusScreen({super.key, this.inlineAd});

  /// Native preloaded by the previous step's ad provider — owned and disposed
  /// by this screen.
  final InlineAdManager? inlineAd;

  @override
  State<EmploymentStatusScreen> createState() => _EmploymentStatusScreenState();
}

class _EmploymentStatusScreenState extends State<EmploymentStatusScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'employment_status_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoanFinderAdProvider>().preloadAfterStep(3);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  void _next() {
    final formProvider = context.read<LoanFinderProvider>();
    if (formProvider.employmentStatus == null) {
      AnalyticsManager.instance.logEvent(
        name: 'loan_finder_validation_failed',
        parameters: const {'step': 4, 'field': 'employment_status'},
      );
      context.l10n.employmentStatusValidation.showErrorAlert();
      return;
    }
    AnalyticsManager.instance.logEvent(
      name: 'loan_finder_next',
      parameters: {
        'step': 4,
        'employment_status': formProvider.employmentStatus!.name,
      },
    );
    context.read<LoanFinderAdProvider>().next(context, AppRoutes.creditScore);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formProvider = context.watch<LoanFinderProvider>();
    final adProvider = context.watch<LoanFinderAdProvider>();
    final options = [
      _Option(EmploymentStatus.salaried, l10n.employmentSalaried, l10n.employmentSalariedDesc),
      _Option(EmploymentStatus.selfEmployed, l10n.employmentSelfEmployed, l10n.employmentSelfEmployedDesc),
      _Option(EmploymentStatus.businessOwner, l10n.employmentBusinessOwner, l10n.employmentBusinessOwnerDesc),
      _Option(EmploymentStatus.professional, l10n.employmentFreelancer, l10n.employmentFreelancerDesc),
      _Option(EmploymentStatus.retired, l10n.employmentRetired, l10n.employmentRetiredDesc),
    ];
    return LoanFinderLayout(
      stepIndex: 3,
      title: l10n.employmentStatusTitle,
      subtitle: l10n.employmentStatusSubtitle,
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
            selected: formProvider.employmentStatus == option.value,
            onTap: () {
              AnalyticsManager.instance.logEvent(
                name: 'loan_finder_option_selected',
                parameters: {'step': 4, 'employment_status': option.value.name},
              );
              context.read<LoanFinderProvider>().setEmploymentStatus(option.value);
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
  final EmploymentStatus value;
  final String label;
  final String subTitle;

}
