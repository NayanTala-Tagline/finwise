import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_summary_background.dart';

// ── Severity enum ──────────────────────────────────────────────────────────────

enum _Severity { critical, high, medium }

// ── Data models ────────────────────────────────────────────────────────────────

class _StepItem {
  const _StepItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
  });
  final SvgGenImage icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;
}

class _StrategyItem {
  const _StrategyItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.description,
  });
  final SvgGenImage icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final String description;
}

class _CreditFactor {
  const _CreditFactor({
    required this.title,
    required this.percent,
    required this.impact,
    required this.doItem,
    required this.dontItem,
  });
  final String title;
  final int percent;
  final String impact;
  final String doItem;
  final String dontItem;
}

class _MistakeItem {
  const _MistakeItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.severity,
    required this.description,
  });
  final SvgGenImage icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final _Severity severity;
  final String description;
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.impact,
    required this.impactColor,
    required this.impactBg,
    required this.description,
  });
  final SvgGenImage icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String impact;
  final Color impactColor;
  final Color impactBg;
  final String description;
}

class _GoalTier {
  const _GoalTier({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.examples,
    required this.strategy,
  });
  final SvgGenImage icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String examples;
  final String strategy;
}

class _AgeGroup {
  const _AgeGroup({
    required this.icon,
    required this.age,
    required this.color,
    required this.bgColor,
    required this.tips,
  });
  final SvgGenImage icon;
  final String age;
  final Color color;
  final Color bgColor;
  final List<String> tips;
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class TipsAdviceScreen extends StatefulWidget {
  const TipsAdviceScreen({super.key});

  @override
  State<TipsAdviceScreen> createState() => _TipsAdviceScreenState();
}

class _TipsAdviceScreenState extends State<TipsAdviceScreen> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'tips_advice_screen');
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.tipsNative;
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
    final steps = [
      _StepItem(
        icon: Assets.personalLoanIcons.icRightCurcle,
        iconColor: const Color(0xFF10B981),
        bgColor: const Color(0xFF10B981).withValues(alpha: 0.08),
        title: context.l10n.tipsStep1Title,
        description: context.l10n.tipsStep1Desc,
      ),
      _StepItem(
        icon: Assets.tipsAdviceIcons.icCalculate,
        iconColor: const Color(0xFF06B6D4),
        bgColor: const Color(0xFF06B6D4).withValues(alpha: 0.08),
        title: context.l10n.tipsStep2Title,
        description: context.l10n.tipsStep2Desc,
      ),
      _StepItem(
        icon: Assets.tipsAdviceIcons.icScore,
        iconColor: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        title: context.l10n.tipsStep3Title,
        description: context.l10n.tipsStep3Desc,
      ),
      _StepItem(
        icon: Assets.personalLoanIcons.icImprovementTips,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        title: context.l10n.tipsStep4Title,
        description: context.l10n.tipsStep4Desc,
      ),
      _StepItem(
        icon: Assets.onboardingIcons.icVerification,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
        title: context.l10n.tipsStep5Title,
        description: context.l10n.tipsStep5Desc,
      ),
    ];

    final strategies = [
      _StrategyItem(
        icon: Assets.tipsAdviceIcons.icEmergency,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: context.l10n.tipsStrategy1Title,
        badge: context.l10n.tipsStrategy1Badge,
        badgeColor: const Color(0xFF2563EB),
        badgeBg: const Color(0xFFEFF6FF),
        description: context.l10n.tipsStrategy1Desc,
      ),
      _StrategyItem(
        icon: Assets.personalLoanIcons.icClock,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: context.l10n.tipsStrategy2Title,
        badge: context.l10n.tipsImpactHigh,
        badgeColor: const Color(0xFF0D9488),
        badgeBg: const Color(0xFFEFFAF9),
        description: context.l10n.tipsStrategy2Desc,
      ),
      _StrategyItem(
        icon: Assets.homeIcons.icCreditCard,
        iconColor: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        title: context.l10n.tipsStrategy3Title,
        badge: context.l10n.tipsStrategy3Badge,
        badgeColor: const Color(0xFF7C3AED),
        badgeBg: const Color(0xFFF5F3FF),
        description: context.l10n.tipsStrategy3Desc,
      ),
      _StrategyItem(
        icon: Assets.tipsAdviceIcons.icCalculate,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: context.l10n.tipsStrategy4Title,
        badge: context.l10n.tipsStrategy4Badge,
        badgeColor: const Color(0xFFF59E0B),
        badgeBg: const Color(0xFFFFFBEB),
        description: context.l10n.tipsStrategy4Desc,
      ),
    ];

    final creditFactors = [
      _CreditFactor(
        title: context.l10n.creditScoreStep1Title,
        percent: 35,
        impact: context.l10n.tipsImpactHigh,
        doItem: context.l10n.tipsCreditFactor1DoItem,
        dontItem: context.l10n.tipsCreditFactor1DontItem,
      ),
      _CreditFactor(
        title: context.l10n.tipsCreditFactor2Title,
        percent: 30,
        impact: context.l10n.tipsImpactHigh,
        doItem: context.l10n.tipsCreditFactor2DoItem,
        dontItem: context.l10n.tipsCreditFactor2DontItem,
      ),
      _CreditFactor(
        title: context.l10n.tipsCreditFactorAge,
        percent: 15,
        impact: context.l10n.tipsImpactMedium,
        doItem: context.l10n.tipsCreditFactor3DoItem,
        dontItem: context.l10n.tipsCreditFactor3DontItem,
      ),
      _CreditFactor(
        title: context.l10n.tipsCreditFactorMix,
        percent: 10,
        impact: context.l10n.tipsImpactMedium,
        doItem: context.l10n.tipsCreditFactor4DoItem,
        dontItem: context.l10n.tipsCreditFactor4DontItem,
      ),
      _CreditFactor(
        title: context.l10n.tipsCreditFactorNewCredit,
        percent: 10,
        impact: context.l10n.tipsImpactLow,
        doItem: context.l10n.tipsCreditFactor5DoItem,
        dontItem: context.l10n.tipsCreditFactor5DontItem,
      ),
    ];

    final mistakes = [
      _MistakeItem(
        icon: Assets.tipsAdviceIcons.icEmergency,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: context.l10n.tipsMistake1Title,
        severity: _Severity.critical,
        description: context.l10n.tipsMistake1Desc,
      ),
      _MistakeItem(
        icon: Assets.homeIcons.icCreditCard,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: context.l10n.tipsMistake2Title,
        severity: _Severity.high,
        description: context.l10n.tipsMistake2Desc,
      ),
      _MistakeItem(
        icon: Assets.onboardingIcons.icWelcome,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: context.l10n.tipsMistake3Title,
        severity: _Severity.high,
        description: context.l10n.tipsMistake3Desc,
      ),
      _MistakeItem(
        icon: Assets.onboardingIcons.icVerification,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: context.l10n.tipsMistake4Title,
        severity: _Severity.critical,
        description: context.l10n.tipsMistake4Desc,
      ),
      _MistakeItem(
        icon: Assets.personalLoanIcons.icImprovementTips,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: context.l10n.tipsMistake5Title,
        severity: _Severity.medium,
        description: context.l10n.tipsMistake5Desc,
      ),
    ];

    final paymentMethods = [
      _PaymentMethod(
        icon: Assets.tipsAdviceIcons.icCalculate,
        iconColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        title: context.l10n.tipsPayment1Title,
        impact: context.l10n.tipsSeverityHigh,
        impactColor: const Color(0xFF22C55E),
        impactBg: const Color(0xFFF0FDF4),
        description: context.l10n.tipsPayment1Desc,
      ),
      _PaymentMethod(
        icon: Assets.tipsAdviceIcons.icBag,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: context.l10n.tipsPayment2Title,
        impact: context.l10n.tipsPayment2Impact,
        impactColor: const Color(0xFF2563EB),
        impactBg: const Color(0xFFEFF6FF),
        description: context.l10n.tipsPayment2Desc,
      ),
      _PaymentMethod(
        icon: Assets.personalLoanIcons.icInstantApproval,
        iconColor: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        title: context.l10n.tipsPayment3Title,
        impact: context.l10n.tipsSeverityMedium,
        impactColor: const Color(0xFFF59E0B),
        impactBg: const Color(0xFFFFFBEB),
        description: context.l10n.tipsPayment3Desc,
      ),
      _PaymentMethod(
        icon: Assets.tipsAdviceIcons.icClarity,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: context.l10n.tipsPayment4Title,
        impact: context.l10n.tipsPayment4Impact,
        impactColor: const Color(0xFF7C3AED),
        impactBg: const Color(0xFFF5F3FF),
        description: context.l10n.tipsPayment4Desc,
      ),
    ];

    final goalTiers = [
      _GoalTier(
        icon: Assets.personalLoanIcons.icInstantApproval,
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: context.l10n.tipsGoalShortTerm,
        examples: context.l10n.tipsGoalShortTermExamples,
        strategy: context.l10n.tipsGoalShortTermStrategy,
      ),
      _GoalTier(
        icon: Assets.tipsAdviceIcons.icCalculate,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: context.l10n.tipsGoalMidTerm,
        examples: context.l10n.tipsGoalMidTermExamples,
        strategy: context.l10n.tipsGoalMidTermStrategy,
      ),
      _GoalTier(
        icon: Assets.tipsAdviceIcons.icScore,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        title: context.l10n.tipsGoalLongTerm,
        examples: context.l10n.tipsGoalLongTermExamples,
        strategy: context.l10n.tipsGoalLongTermStrategy,
      ),
    ];

    final ageGroups = [
      _AgeGroup(
        icon: Assets.onboardingIcons.icEducation,
        age: context.l10n.tipsAge20s,
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        tips: [
          context.l10n.tipsAge20sTip1,
          context.l10n.tipsAge20sTip2,
          context.l10n.tipsAge20sTip3,
          context.l10n.tipsAge20sTip4,
        ],
      ),
      _AgeGroup(
        icon: Assets.tipsAdviceIcons.icBag,
        age: context.l10n.tipsAge30s,
        color: const Color(0xFF06B6D4),
        bgColor: Color(0xFF06B6D4).withValues(alpha: 0.08),
        tips: [
          context.l10n.tipsAge30sTip1,
          context.l10n.tipsAge30sTip2,
          context.l10n.tipsAge30sTip3,
          context.l10n.tipsAge30sTip4,
        ],
      ),
      _AgeGroup(
        icon: Assets.onboardingIcons.icHome,
        age: context.l10n.tipsAge40s,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        tips: [
          context.l10n.tipsAge40sTip1,
          context.l10n.tipsAge40sTip2,
          context.l10n.tipsAge40sTip3,
          context.l10n.tipsAge40sTip4,
        ],
      ),
      _AgeGroup(
        icon: Assets.onboardingIcons.icPersonal,
        age: context.l10n.tipsAge50s,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        tips: [
          context.l10n.tipsAge50sTip1,
          context.l10n.tipsAge50sTip2,
          context.l10n.tipsAge50sTip3,
          context.l10n.tipsAge50sTip4,
        ],
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: context.themeColors.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── AppSummaryBackground header ────────────────────────────
            _TipsHeader(onBack: () => NavigationHelper().handleBackPress(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w20,vertical: AppSize.h20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     Text(
                      context.l10n.tipsWhyPlanningTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                       ),
                    ),
                    SizedBox(height: AppSize.h12),
                    const _WhyPlanningCard(),
                    SizedBox(height: AppSize.h15),
                    // ── Before Taking a Loan ───────────────────────────
                    Text(
                      context.l10n.tipsBeforeLoanTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                       ),
                    ),

                    SizedBox(height: AppSize.h14),
                    ...steps.asMap().entries.map(
                          (e) => _StepCard(item: e.value, stepNumber: e.key + 1),
                        ),
                    SizedBox(height: AppSize.h15),
                    // ── Smart Borrowing Strategies ─────────────────────
                    Text(
                      context.l10n.tipsSmartBorrowingTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                       ),
                    ),

                    SizedBox(height: AppSize.h14),
                    ...strategies.map((s) => _StrategyCard(item: s)),
                    SizedBox(height: AppSize.h15),


                    // ── Credit Score ───────────────────────────────────
                    Text(
                      context.l10n.tipsCreditScoreSectionTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSize.h14),
                    _CreditScoreCard(factors: creditFactors),
                    SizedBox(height: AppSize.h15),
                    Text(
                      context.l10n.tipsMistakesTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSize.h14),
                    ...mistakes.map((m) => _MistakeCard(item: m)),
                    SizedBox(height: AppSize.h15),
                    Text(
                      context.l10n.tipsPaymentMethodsTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSize.h14),
                    ...paymentMethods.map((p) => _PaymentMethodCard(item: p)),
                    SizedBox(height: AppSize.h15),
                    // ── Financial Goals ────────────────────────────────
                    Text(
                      context.l10n.tipsGoalsTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: AppSize.h14),
                    _GoalsCard(tiers: goalTiers),
                    SizedBox(height: AppSize.h15),
                    // ── Invest or Pay Debt ─────────────────────────────
                    Text(
                      context.l10n.tipsInvestVsDebtTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),


                    SizedBox(height: AppSize.h14),
                    const _InvestVsDebtCard(),
                    SizedBox(height: AppSize.h15),
                    // ── Age Specific Guidance ──────────────────────────
                    // ── Invest or Pay Debt ─────────────────────────────
                    Text(
                      context.l10n.tipsAgeGuidanceTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: AppSize.h14),
                    ...ageGroups.map((a) => _AgeCard(item: a)),
                    SizedBox(height: AppSize.h20),
                    // ── CTA ────────────────────────────────────────────
                    const _CtaCard(),
                    SizedBox(height: AppSize.h8),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: AdSlot(ad: _inlineAd, safeAreaBottom: false),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _TipsHeader extends StatelessWidget {
  const _TipsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppSummaryBackground(
      gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
        borderRadius:   BorderRadius.only(
        bottomLeft: Radius.circular(AppSize.r24),
        bottomRight: Radius.circular(AppSize.r24),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h8, AppSize.w16, AppSize.h24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Assets.personalLoanIcons.icBack.svg(
                  width: AppSize.sp26,
                  height: AppSize.sp26,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: AppSize.h16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.homeTipsAdvice,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.themeTextColors.secondaryTextColor,
                          fontSize: AppSize.sp28,
                        ),
                      ),
                      SizedBox(height: AppSize.h6),
                      Text(
                        context.l10n.tipsAdviceSubtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.themeTextColors.secondaryTextColor,
                          fontSize: AppSize.sp13,
                        ),
                      ),
                    ],
                  ),


            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: AppSize.sp12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          subtitle,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

// ── Shared card decoration ─────────────────────────────────────────────────────

BoxDecoration _cardDeco({Color? border}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSize.r16),
      border: Border.all(color: border ?? const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
      ],
    );

// ── Why Planning Card ──────────────────────────────────────────────────────────

class _WhyPlanningCard extends StatelessWidget {
  const _WhyPlanningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h20),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSize.w44,
                height: AppSize.h44,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFF6FF)),
                child: Center(
                  child: Assets.personalLoanIcons.icImprovementTips.svg(
                    width: AppSize.w22,
                    height: AppSize.h22,
                    colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.tipsBuildSecureFutureTitle,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: AppSize.h6),
                    Text(
                      context.l10n.tipsBuildSecureFutureDesc,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: AppSize.sp12,
                        color: const Color(0xFF64748B),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h16),

          Row(
            children: [
              _StatItem(
                icon: Assets.tipsAdviceIcons.icClarity,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFF10B981).withValues(alpha: 0.08),
                label: context.l10n.tipsClarity,
              ),
               _StatItem(
                icon: Assets.tipsAdviceIcons.icControl,
                iconColor: const Color(0xFF06B6D4),
                bgColor: const Color(0xFF06B6D4).withValues(alpha: 0.08),
                label: context.l10n.tipsControl,
              ),
               _StatItem(
                icon: Assets.onboardingIcons.icStars,
                iconColor: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                label: context.l10n.tipsConfidence,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.iconColor, required this.bgColor, required this.label});

  final SvgGenImage icon;
  final Color iconColor;
  final Color bgColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: AppSize.w40,
            height: AppSize.h40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Center(
              child: icon.svg(
                width: AppSize.w20,
                height: AppSize.h20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(height: AppSize.h6),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: AppSize.sp11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step card ──────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({required this.item, required this.stepNumber});

  final _StepItem item;
  final int stepNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.h10),
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
            width: AppSize.w32,
            height: AppSize.h32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: item.bgColor),
            child: Center(
              child: item.icon.svg(
                width: AppSize.w16,
                height: AppSize.h16,
                colorFilter: ColorFilter.mode(item.iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: AppSize.h5),
                Text(
                  item.description,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: const Color(0xFF64748B),
                    height: 1.5,
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

// ── Strategy card ──────────────────────────────────────────────────────────────

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({required this.item});

  final _StrategyItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.h10),
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(border: const Color(0xFFF1F5F9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

               
              Expanded(
                child: Text(
                  item.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp14,
                   ),
                ),
              ),
              SizedBox(width: AppSize.w8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w8, vertical: AppSize.h4),
                decoration: BoxDecoration(
                  color: Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(AppSize.r20),
                ),
                child: Text(
                  item.badge,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontSize: AppSize.sp12,
                    ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h8),
          Text(
            item.description,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp13,
              color: context.themeTextColors.descriptionColor
             ),
          ),
        ],
      ),
    );
  }
}

// ── Credit Score Card ──────────────────────────────────────────────────────────

class _CreditScoreCard extends StatelessWidget {
  const _CreditScoreCard({required this.factors});

  final List<_CreditFactor> factors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h20),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < factors.length; i++) ...[
            _CreditFactorRow(factor: factors[i]),
            if (i < factors.length - 1) ...[
              SizedBox(height: AppSize.h14),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              SizedBox(height: AppSize.h14),
            ],
          ],
        ],
      ),
    );
  }
}

class _CreditFactorRow extends StatelessWidget {
  const _CreditFactorRow({required this.factor});

  final _CreditFactor factor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + impact badge
        Row(
          children: [
            Expanded(
              child: Text(
                '${factor.title} (${factor.percent}%)',
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            SizedBox(width: AppSize.w8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w10, vertical: AppSize.h4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppSize.r20),
              ),
              child: Text(
                factor.impact,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: AppSize.sp12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.h10),
        // Do item
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSize.h2),
              child: Assets.personalLoanIcons.icRightCurcle.svg(
                width: AppSize.w16,
                height: AppSize.h16,
                colorFilter: const ColorFilter.mode(Color(0xFF22C55E), BlendMode.srcIn),
              ),
            ),
            SizedBox(width: AppSize.w8),
            Expanded(
              child: Text(
                factor.doItem,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: AppSize.sp12,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.h6),
        // Don't item
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSize.h2),
              child: Assets.requiredDocuments.icImportantNote.svg(
                width: AppSize.w16,
                height: AppSize.h16,
                colorFilter: const ColorFilter.mode(Color(0xFFEF4444), BlendMode.srcIn),
              ),
            ),
            SizedBox(width: AppSize.w8),
            Expanded(
              child: Text(
                factor.dontItem,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: AppSize.sp12,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Mistake card ───────────────────────────────────────────────────────────────

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.item});

  final _MistakeItem item;

  (Color bg, Color text) _severityColors() {
    switch (item.severity) {
      case _Severity.critical:
        return (const Color(0xFFFEE2E2), const Color(0xFFEF4444));
      case _Severity.high:
        return (const Color(0xFFF1F5F9), const Color(0xFF475569));
      case _Severity.medium:
        return (const Color(0xFFF1F5F9), const Color(0xFF475569));
    }
  }

  String _severityLabel(BuildContext context) {
    switch (item.severity) {
      case _Severity.critical: return context.l10n.tipsSeverityCritical;
      case _Severity.high: return context.l10n.tipsSeverityHigh;
      case _Severity.medium: return context.l10n.tipsSeverityMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _severityColors();
    final badgeBg = colors.$1;
    final badgeText = colors.$2;

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.h10),
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge — small rounded square
          Container(
            padding: EdgeInsets.all(AppSize.sp8),
            decoration: BoxDecoration(
              color: item.bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: item.icon.svg(
                width: AppSize.w20,
                height: AppSize.h20,
                colorFilter: ColorFilter.mode(item.iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + severity badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontSize: AppSize.sp14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSize.w8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.w8,
                        vertical: AppSize.h4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(AppSize.r6),
                      ),
                      child: Text(
                        _severityLabel(context),
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: AppSize.sp11,
                          fontWeight: FontWeight.w600,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h6),
                Text(
                  item.description,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: const Color(0xFF64748B),
                    height: 1.5,
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

// ── Payment Method card ────────────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.item});

  final _PaymentMethod item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.h10),
      padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w10, vertical: AppSize.h5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(AppSize.r6),
                ),
                child: Text(
                  item.impact,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontSize: AppSize.sp12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h8),
          Text(
            item.description,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: AppSize.sp12,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Goal card ──────────────────────────────────────────────────────────────────

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.tiers});

  final List<_GoalTier> tiers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: List.generate(tiers.length, (i) {
          final tier = tiers[i];
          final isLast = i == tiers.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(AppSize.h16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: AppSize.w40,
                          height: AppSize.h40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tier.color.withValues(alpha: 0.12),
                          ),
                          child: Center(
                            child: tier.icon.svg(
                              width: AppSize.w20,
                              height: AppSize.h20,
                              colorFilter: ColorFilter.mode(tier.color, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSize.w12),
                        Expanded(
                          child: Text(
                            tier.title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontSize: AppSize.sp15,
                              ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.h10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: context.l10n.tipsGoalExamplesLabel,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: AppSize.sp13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          TextSpan(
                            text: tier.examples,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontSize: AppSize.sp14,
                              color: context.themeTextColors.descriptionColor
                             ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.h6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: context.l10n.tipsGoalStrategyLabel,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: AppSize.sp13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          TextSpan(
                            text: tier.strategy,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: AppSize.sp13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }
}

// ── Invest vs Debt card ────────────────────────────────────────────────────────

class _InvestVsDebtCard extends StatelessWidget {
  const _InvestVsDebtCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InvestDebtSection(
          icon: Assets.tipsAdviceIcons.icEmergency,
          iconColor: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEF2F2),
          title: context.l10n.tipsPayDebtFirstTitle,
          bullets: [
            context.l10n.tipsPayDebtBullet1,
            context.l10n.tipsPayDebtBullet2,
            context.l10n.tipsPayDebtBullet3,
            context.l10n.tipsPayDebtBullet4,
          ],
        ),
        SizedBox(height: AppSize.h10),
        _InvestDebtSection(
          icon: Assets.personalLoanIcons.icRightCurcle,
          iconColor: const Color(0xFF22C55E),
          bgColor: const Color(0xFFF0FDF4),
          title: context.l10n.tipsInvestAlongsideTitle,
          bullets: [
            context.l10n.tipsInvestBullet1,
            context.l10n.tipsInvestBullet2,
            context.l10n.tipsInvestBullet3,
            context.l10n.tipsInvestBullet4,
          ],
        ),
        SizedBox(height: AppSize.h10),
        _InvestDebtSection(
          icon: Assets.onboardingIcons.icStars,
          iconColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
          title: context.l10n.tipsBestApproachTitle,
          description: context.l10n.tipsBestApproachDesc,
        ),
      ],
    );
  }
}

class _InvestDebtSection extends StatelessWidget {
  const _InvestDebtSection({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    this.bullets = const [],
    this.description,
  });

  final SvgGenImage icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final List<String> bullets;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSize.r12),
        border: Border.all(color: iconColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon.svg(
                width: AppSize.w20,
                height: AppSize.h20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              SizedBox(width: AppSize.w8),
              Flexible(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp14,
                    ),
                ),
              ),
            ],
          ),
          if (bullets.isNotEmpty) ...[
            SizedBox(height: AppSize.h10),
            ...bullets.map(
              (b) => Padding(
                padding: EdgeInsets.only(bottom: AppSize.h5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '· ',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: AppSize.sp14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: AppSize.sp12,
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (description != null) ...[
            SizedBox(height: AppSize.h8),
            Text(
              description!,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.sp12,
                color: const Color(0xFF475569),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Age card ───────────────────────────────────────────────────────────────────

class _AgeCard extends StatelessWidget {
  const _AgeCard({required this.item});

  final _AgeGroup item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.h10),
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.w44,
                height: AppSize.h44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.bgColor,
                ),
                child: Center(
                  child: item.icon.svg(
                    width: AppSize.w22,
                    height: AppSize.h22,
                    colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w12),
              Text(
                item.age,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h12),
          ...item.tips.map(
            (t) => Padding(
              padding: EdgeInsets.only(bottom: AppSize.h8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: AppSize.h2),
                    child: Assets.personalLoanIcons.icRightCurcle.svg(
                      width: AppSize.w14,
                      height: AppSize.h14,
                      colorFilter: const ColorFilter.mode(Color(0xFF22C55E), BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: AppSize.w8),
                  Expanded(
                    child: Text(
                      t,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: AppSize.sp13,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CTA card ───────────────────────────────────────────────────────────────────

class _CtaCard extends StatelessWidget {
  const _CtaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.h16),
      decoration: _cardDeco(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Container(
            width: AppSize.w44,
            height: AppSize.h44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.themeTextColors.primaryTextColor.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Assets.onboardingIcons.icMakeSmart.svg(
                width: AppSize.w22,
                height: AppSize.h22,
                colorFilter:   ColorFilter.mode(context.themeTextColors.primaryTextColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.tipsCtaTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: AppSize.h6),
                Text(
                  context.l10n.tipsCtaDesc,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp13,
                    color: const Color(0xFF64748B),
                   ),
                ),
                SizedBox(height: AppSize.h14),
                Row(
                  children: [
                    Text(
                      context.l10n.tipsCtaButton,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: AppSize.sp14,
                        fontWeight: FontWeight.w700,
                        color: context.themeTextColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(width: AppSize.w4),
                    Icon(Icons.arrow_forward_rounded, color: const Color(0xFF0D9488), size: AppSize.sp16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
