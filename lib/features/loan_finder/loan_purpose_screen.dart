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
import '../../widgets/app_textfield.dart';
import 'provider/loan_finder_ad_provider.dart';
import 'provider/loan_finder_provider.dart';
import 'widgets/loan_finder_layout.dart';
import 'widgets/loan_finder_option_tile.dart';

class LoanPurposeScreen extends StatefulWidget {
  const LoanPurposeScreen({super.key});

  @override
  State<LoanPurposeScreen> createState() => _LoanPurposeScreenState();
}

class _LoanPurposeScreenState extends State<LoanPurposeScreen> {
  /// Native for step 1. First step has no predecessor to hand off from, so we
  /// load it locally and dispose it here.
  InlineAdManager? _inlineAd;
  final TextEditingController _downPaymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'loan_purpose_screen');
    _loadOwnInline();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoanFinderAdProvider>().preloadAfterStep(0);
    });
  }

  void _loadOwnInline() {
    final data = LoanFinderAdProvider.nativeForStep(0);
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    _downPaymentController.dispose();
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  void _next() {
    final formProvider = context.read<LoanFinderProvider>();
    if (formProvider.purpose == null) {
      AnalyticsManager.instance.logEvent(
        name: 'loan_finder_validation_failed',
        parameters: const {'step': 1, 'field': 'purpose'},
      );
      context.l10n.loanPurposeValidation.showErrorAlert();
      return;
    }
    AnalyticsManager.instance.logEvent(
      name: 'loan_finder_next',
      parameters: {
        'step': 1,
        'purpose': formProvider.purpose!.name,
      },
    );
    context.read<LoanFinderAdProvider>().next(context, AppRoutes.loanAmount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formProvider = context.watch<LoanFinderProvider>();
    final adProvider = context.watch<LoanFinderAdProvider>();
    final options = [
      _PurposeOption(LoanPurpose.homePurchase, l10n.loanPurposeHomePurchase, Assets.onboardingIcons.icHome),
      _PurposeOption(LoanPurpose.vehiclePurchase, l10n.loanPurposeVehicle, Assets.onboardingIcons.icVehicle),
      _PurposeOption(LoanPurpose.education, l10n.onboarding1Education, Assets.onboardingIcons.icEducation),
      _PurposeOption(LoanPurpose.business, l10n.onboarding1Business, Assets.onboardingIcons.icBusiness),
      _PurposeOption(LoanPurpose.personalExpenses, l10n.loanPurposePersonalNeeds, Assets.homeIcons.icUser),
      _PurposeOption(LoanPurpose.debit, l10n.loanPurposeDebtConsolidation, Assets.homeIcons.icCreditCard),
      _PurposeOption(LoanPurpose.other, l10n.loanPurposeOther, Assets.homeIcons.icCreditCard),
    ];

    final showDownPayment = formProvider.purpose == LoanPurpose.other;

    final mainOptions = options.sublist(0, options.length - 1);
    final otherOption = options.last;

    Widget buildTile(_PurposeOption option, int index) {
      final isSelected = formProvider.purpose == option.value;
      final isOther = option.value == LoanPurpose.other;
      return GestureDetector(
        onTap: () {
          AnalyticsManager.instance.logEvent(
            name: 'loan_finder_option_selected',
            parameters: {'step': 1, 'purpose': option.value.name},
          );
          context.read<LoanFinderProvider>().setPurpose(option.value);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSize.h10, horizontal: AppSize.w10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(isOther ? AppSize.r30 : AppSize.r16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            gradient: isSelected
                ? LinearGradient(colors: [context.themeColors.primary, const Color(0xff153885)])
                : const LinearGradient(colors: [Colors.white, Color(0xffE7F1FF)]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isOther) ...[
                Container(
                  padding: EdgeInsets.all(AppSize.sp8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.themeColors.whiteColor.withValues(alpha: 0.11)
                        : context.themeColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSize.r12),
                  ),
                  child: option.icon.svg(
                    width: AppSize.w28,
                    height: AppSize.h28,
                    colorFilter: isSelected
                        ? const ColorFilter.mode(Color(0xFFffffff), BlendMode.srcIn)
                        : const ColorFilter.mode(Color(0xFF64748B), BlendMode.srcIn),
                  ),
                ),
                SizedBox(height: AppSize.h8),
              ],
              Flexible(
                child: Text(
                  option.label,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? context.themeTextColors.secondaryTextColor
                        : context.themeTextColors.descriptionColor,
                    fontSize: AppSize.sp13,
                  ),
                  textAlign: TextAlign.start,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: (300 + index * 55).ms, duration: 380.ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            delay: (300 + index * 55).ms,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          );
    }

    return LoanFinderLayout(
      stepIndex: 0,
      title: l10n.loanPurposeTitle,
      subtitle: l10n.loanPurposeSubtitle,
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: _inlineAd),
      onNextPressed: _next,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSize.h16),

            // 6-item grid (excludes "Other")
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSize.w12,
                mainAxisSpacing: AppSize.h12,
                childAspectRatio: 1.3,
              ),
              itemCount: mainOptions.length,
              itemBuilder: (context, index) => buildTile(mainOptions[index], index),
            ),
            SizedBox(height: AppSize.h12),
            // "Other" as a half-width tile, height driven by content
            Row(
              children: [
                Expanded(child: buildTile(otherOption, mainOptions.length)),
                SizedBox(width: AppSize.w12),
                const Expanded(child: SizedBox()),
              ],
            ),
            // Down payment section (shown when "Other" is selected)
            if (showDownPayment) ...[
              SizedBox(height: AppSize.h12),
              AppTextFormField(
                title: l10n.loanPurposeDownPayment,
                controller: _downPaymentController,
                keyboardType: TextInputType.number,
                hintText: l10n.loanPurposeDownPaymentHint,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
            ],

            SizedBox(height: AppSize.h24),
          ],
        ),
      ),
    );
  }
}

class _PurposeOption {
  const _PurposeOption(this.value, this.label, this.icon);
  final LoanPurpose value;
  final String label;
  final SvgGenImage icon;
}
