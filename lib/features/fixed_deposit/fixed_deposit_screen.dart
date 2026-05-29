import 'dart:async';

import 'package:ad_manager/inline_ad_manager.dart';
import 'package:finwise/utils/remote_config.dart';
import 'package:finwise/widgets/ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_summary_background.dart';
import 'provider/fixed_deposit_provider.dart';
import 'widgets/fd_calculator_sheet.dart';

class FixedDepositScreen extends StatelessWidget {
  const FixedDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FixedDepositProvider(),
      child: const _FdDetailView(),
    );
  }
}

class _FdDetailView extends StatefulWidget {
  const _FdDetailView();

  @override
  State<_FdDetailView> createState() => _FdDetailViewState();
}

class _FdDetailViewState extends State<_FdDetailView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _stepsKey = GlobalKey();

  static const Color _green = Color(0xFF059669);
  static const Color _greenDark = Color(0xFF047857);

  InlineAdManager? _inlineAd;

  void _openCalculator(BuildContext context) {
    final provider = context.read<FixedDepositProvider>();
    NavigationHelper().navigateWithAdCheck(context, () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const FdCalculatorSheet(),
          ),
        ),
      );
    });
  }

  void _scrollToSteps() {
    final ctx = _stepsKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      alignment: 0.0,
    );
  }

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'fixed_deposit_screen');
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.fixedDepositNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = [
      (
        icon: 'assets/personal_loan_icons/ic_secure.svg',
        title: l10n.fdGuaranteedReturns,
        subtitle: l10n.fdGuaranteedReturnsDesc,
      ),
      (
        icon: 'assets/temperature_icons/ic_Help_center.svg',
        title: l10n.fdCompoundInterest,
        subtitle: l10n.fdCompoundInterestDesc,
      ),
      (
        icon: 'assets/onboarding_icons/ic_currency.svg',
        title: l10n.fdPrematureWithdrawal,
        subtitle: l10n.fdPrematureWithdrawalDesc,
      ),
      (
        icon: 'assets/tips_advice_icons/ic_score.svg',
        title: l10n.fdTaxSaving,
        subtitle: l10n.fdTaxSavingDesc,
      ),
    ];

    final useCases = [
      l10n.fdUseCaseEmergencyFund,
      l10n.fdUseCaseSpecificGoals,
      l10n.fdUseCaseSurplusFunds,
      l10n.fdUseCaseTaxSaving,
      l10n.fdUseCaseSeniorCitizen,
      l10n.fdUseCaseLadderStrategy,
    ];

    final steps = [
      (title: l10n.fdStep1Title, subtitle: l10n.fdStep1Subtitle),
      (title: l10n.fdStep2Title, subtitle: l10n.fdStep2Subtitle),
      (title: l10n.fdStep3Title, subtitle: l10n.fdStep3Subtitle),
      (title: l10n.fdStep4Title, subtitle: l10n.fdStep4Subtitle),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            AppSummaryBackground(
              gradientColors: const [_green, _greenDark],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSize.r24),
                bottomRight: Radius.circular(AppSize.r24),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.w16,
                    AppSize.h8,
                    AppSize.w16,
                    AppSize.h24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => NavigationHelper().handleBackPress(context),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: AppSize.sp22,
                        ),
                      ),
                      SizedBox(height: AppSize.h16),
                      Text(
                        l10n.fdTitle,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: AppSize.sp26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSize.h6),
                      Text(
                        l10n.fdSubtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: AppSize.sp13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSize.w16,
                  AppSize.h20,
                  AppSize.w16,
                  AppSize.h16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Assets.personalLoanIcons.icInstantApproval.svg(width: AppSize.w20, height: AppSize.h20),
                      title: l10n.fdKeyFeatures,
                    ),
                    SizedBox(height: AppSize.h12),
                    _FeaturesGrid(features: features, accentColor: _green),
                    SizedBox(height: AppSize.h20),
                    _SectionHeader(
                      icon: Assets.homeIcons.icDocuments.svg(width: AppSize.w20, height: AppSize.h20),
                      title: l10n.fdCommonUseCases,
                    ),
                    SizedBox(height: AppSize.h12),
                    _UseCasesCard(useCases: useCases),
                    SizedBox(height: AppSize.h20),
                    KeyedSubtree(
                      key: _stepsKey,
                      child: _SectionHeader(
                        icon: Assets.personalLoanIcons.icClock.svg(width: AppSize.w20, height: AppSize.h20),
                        title: l10n.fdApplicationProcess,
                      ),
                    ),
                    SizedBox(height: AppSize.h12),
                    _StepsCard(steps: steps, accentColor: _green),
                    SizedBox(height: AppSize.h12),
                    _TrustBadgeCard(accentColor: _green),
                    SizedBox(height: AppSize.h8),
                  ],
                ),
              ),
            ),

            AdSlot(ad: _inlineAd, safeAreaBottom: false),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26000000),
                    offset: Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h8, AppSize.w16, AppSize.h0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        text: l10n.fdCalculateButton,
                        suffixIcon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: AppSize.sp18),
                        onPressed: () => _openCalculator(context),
                      ),
                      AppButton(
                        text: l10n.fdViewStepsButton,
                        isOutlined: true,
                        onPressed: _scrollToSteps,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final Widget icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(width: AppSize.w10),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: AppSize.sp16,
          ),
        ),
      ],
    );
  }
}

// ── Key Features 2×2 grid ──────────────────────────────────────────────────────

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({required this.features, required this.accentColor});

  final List<({String icon, String title, String subtitle})> features;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate((features.length / 2).ceil(), (rowIndex) {
        final left = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(top: rowIndex > 0 ? AppSize.h12 : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _FeatureCard(feature: features[left], accentColor: accentColor)),
                SizedBox(width: AppSize.w12),
                Expanded(
                  child: right < features.length
                      ? _FeatureCard(feature: features[right], accentColor: accentColor)
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.accentColor});

  final ({String icon, String title, String subtitle}) feature;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.w36,
            height: AppSize.h36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSize.r8),
            ),
            child: Center(
              child: SvgPicture.asset(
                feature.icon,
                width: AppSize.w20,
                height: AppSize.h20,
                colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(height: AppSize.h10),
          Text(
            feature.title,
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSize.h4),
          Text(
            feature.subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: AppSize.sp12,
              color: context.themeTextColors.descriptionColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Use Cases Card ─────────────────────────────────────────────────────────────

class _UseCasesCard extends StatelessWidget {
  const _UseCasesCard({required this.useCases});

  final List<String> useCases;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: useCases.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: entry.key < useCases.length - 1 ? AppSize.h12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSize.sp2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF059669).withValues(alpha: 0.08),
                  ),
                  child: Icon(Icons.done, color: const Color(0xFF059669), size: AppSize.sp15),
                ),
                SizedBox(width: AppSize.w10),
                Expanded(
                  child: Text(
                    entry.value,
                    style: context.textTheme.bodyMedium?.copyWith(fontSize: AppSize.sp14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Application Process Steps ──────────────────────────────────────────────────

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps, required this.accentColor});

  final List<({String title, String subtitle})> steps;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i < steps.length - 1 ? AppSize.h10 : 0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSize.r12),
              boxShadow: const [
                BoxShadow(color: Color(0x0D000000), blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: AppSize.w36,
                  height: AppSize.h36,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSize.sp14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: AppSize.h4),
                      Text(
                        step.subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: AppSize.sp12,
                          color: context.themeTextColors.descriptionColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Trust Badge Card ───────────────────────────────────────────────────────────

class _TrustBadgeCard extends StatelessWidget {
  const _TrustBadgeCard({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppSize.w44,
            height: AppSize.h44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_outlined, color: accentColor, size: AppSize.sp22),
          ),
          SizedBox(width: AppSize.w14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.fdSecureTrusted,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSize.h4),
                Text(
                  context.l10n.fdSecureTrustedDesc,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.descriptionColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
