import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_summary_background.dart';

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
  final String severity;
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
        title: 'Assess Your Need',
        description:
            'Determine exactly why you need the loan and whether it\'s truly necessary. Consider alternatives like savings or family support.',
      ),
      _StepItem(
        icon: Assets.tipsAdviceIcons.icCalculate,
        iconColor: const Color(0xFF06B6D4),
        bgColor: const Color(0xFF06B6D4).withValues(alpha: 0.08),
        title: 'Calculate Affordability',
        description:
            'Ensure your EMI stays within 30–40% of your monthly income. Use the Loan Calculator to find a comfortable tenure.',
      ),
      _StepItem(
        icon: Assets.tipsAdviceIcons.icScore,
        iconColor: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        title: 'Check Your Credit Score',
        description:
            'A score above 750 unlocks the best rates. Review your credit report for errors and resolve them before applying.',
      ),
      _StepItem(
        icon: Assets.personalLoanIcons.icImprovementTips,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        title: 'Compare Offers',
        description:
            'Get quotes from at least 3–5 lenders. Compare total cost (interest + fees), not just the EMI amount.',
      ),
      _StepItem(
        icon: Assets.onboardingIcons.icVerification,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
        title: 'Read the Fine Print',
        description:
            'Understand prepayment penalties, processing fees, and foreclosure charges before signing the loan agreement.',
      ),
    ];

    final strategies = [
      _StrategyItem(
        icon: Assets.tipsAdviceIcons.icEmergency,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: 'Choose the Right Tenure',
        badge: 'Pro Tip',
        badgeColor: const Color(0xFF2563EB),
        badgeBg: const Color(0xFFEFF6FF),
        description:
            'Shorter tenure = higher EMI but lower total interest. Find the sweet spot for your budget.',
      ),
      _StrategyItem(
        icon: Assets.personalLoanIcons.icClock,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: 'Make Partial Prepayments',
        badge: 'High Impact',
        badgeColor: const Color(0xFF0D9488),
        badgeBg: const Color(0xFFEFFAF9),
        description:
            'Prepay in the first 5 years when interest component is highest to save lakhs.',
      ),
      _StrategyItem(
        icon: Assets.homeIcons.icCreditCard,
        iconColor: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        title: 'Negotiate Your Interest Rate',
        badge: 'Essential',
        badgeColor: const Color(0xFF7C3AED),
        badgeBg: const Color(0xFFF5F3FF),
        description:
            'Use competing offers as leverage. Even 0.5% reduction saves significant money.',
      ),
      _StrategyItem(
        icon: Assets.tipsAdviceIcons.icCalculate,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: 'Balance Transfer Wisely',
        badge: 'Advanced',
        badgeColor: const Color(0xFFF59E0B),
        badgeBg: const Color(0xFFFFFBEB),
        description:
            'Transfer to lower rates only if savings exceed processing fees and charges.',
      ),
    ];

    final creditFactors = [
      _CreditFactor(
        title: 'Payment History',
        percent: 35,
        impact: 'High Impact',
        doItem: 'Pay all bills on time, every time',
        dontItem: 'Missing even one payment hurts significantly',
      ),
      _CreditFactor(
        title: 'Credit Utilization',
        percent: 30,
        impact: 'High Impact',
        doItem: 'Keep below 30% of your credit limit',
        dontItem: 'Maxing out cards signals financial stress',
      ),
      _CreditFactor(
        title: 'Credit Age',
        percent: 15,
        impact: 'Medium Impact',
        doItem: 'Keep old accounts open, even if unused',
        dontItem: 'Closing oldest card reduces average age',
      ),
      _CreditFactor(
        title: 'Credit Mix',
        percent: 10,
        impact: 'Medium Impact',
        doItem: 'Have a mix: cards, loans, mortgages',
        dontItem: 'Only one type of credit limits score',
      ),
      _CreditFactor(
        title: 'New Credit',
        percent: 10,
        impact: 'Low Impact',
        doItem: 'Apply for credit only when needed',
        dontItem: 'Multiple applications in short time',
      ),
    ];

    final mistakes = [
      _MistakeItem(
        icon: Assets.tipsAdviceIcons.icEmergency,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: 'No Emergency Fund',
        severity: 'Critical',
        description: 'Not having 6 months of expenses saved leads to debt traps during emergencies',
      ),
      _MistakeItem(
        icon: Assets.homeIcons.icCreditCard,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: 'Paying Only Minimum Due',
        severity: 'High',
        description: 'Credit card interest compounds at 36–42% annually — pay full amount always',
      ),
      _MistakeItem(
        icon: Assets.onboardingIcons.icWelcome,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: 'Ignoring Inflation',
        severity: 'High',
        description: 'Money in savings account loses value over time. Invest for growth.',
      ),
      _MistakeItem(
        icon: Assets.onboardingIcons.icVerification,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: 'No Insurance Coverage',
        severity: 'Critical',
        description: 'Health and life insurance protect your family from financial devastation',
      ),
      _MistakeItem(
        icon: Assets.personalLoanIcons.icImprovementTips,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: 'Lifestyle Inflation',
        severity: 'Medium',
        description: 'Increasing expenses with every salary hike prevents wealth building',
      ),
    ];

    final paymentMethods = [
      _PaymentMethod(
        icon: Assets.tipsAdviceIcons.icCalculate,
        iconColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        title: 'Bi-Weekly Payments',
        impact: 'High',
        impactColor: const Color(0xFF22C55E),
        impactBg: const Color(0xFFF0FDF4),
        description:
            'Pay half your EMI every two weeks instead of once a month. This results in one extra payment per year, reducing your loan tenure significantly.',
      ),
      _PaymentMethod(
        icon: Assets.tipsAdviceIcons.icBag,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: 'Lump Sum on Windfalls',
        impact: 'Very High',
        impactColor: const Color(0xFF2563EB),
        impactBg: const Color(0xFFEFF6FF),
        description:
            'Use bonuses, tax refunds, or any unexpected income to make large lump-sum prepayments. This directly reduces principal and total interest.',
      ),
      _PaymentMethod(
        icon: Assets.personalLoanIcons.icInstantApproval,
        iconColor: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        title: 'Step-Up EMI',
        impact: 'Medium',
        impactColor: const Color(0xFFF59E0B),
        impactBg: const Color(0xFFFFFBEB),
        description:
            'Gradually increase your EMI amount each year as your income grows. Even a 5–10% annual increase shortens the loan tenure meaningfully.',
      ),
      _PaymentMethod(
        icon: Assets.tipsAdviceIcons.icClarity,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        title: 'Hybrid Approach',
        impact: 'Variable',
        impactColor: const Color(0xFF7C3AED),
        impactBg: const Color(0xFFF5F3FF),
        description:
            'Combine regular part-prepayments with step-up EMIs for maximum impact. Adjust based on cash flow while keeping savings goals intact.',
      ),
    ];

    final goalTiers = [
      _GoalTier(
        icon: Assets.personalLoanIcons.icInstantApproval,
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        title: 'Short-Term (0-2 years)',
        examples: 'Emergency fund, vacation, gadgets',
        strategy: 'High-liquidity savings, FD, liquid funds',
      ),
      _GoalTier(
        icon: Assets.tipsAdviceIcons.icCalculate,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        title: 'Mid-Term (2-5 years)',
        examples: 'Car, wedding, home down payment',
        strategy: 'Balanced portfolio: FD + debt funds + some equity',
      ),
      _GoalTier(
        icon: Assets.tipsAdviceIcons.icScore,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        title: 'Long-Term (5+ years)',
        examples: 'Retirement, child education, wealth building',
        strategy: 'Equity-heavy portfolio, PPF, NPS, SIP in mutual funds',
      ),
    ];

    final ageGroups = [
      _AgeGroup(
        icon: Assets.onboardingIcons.icEducation,
        age: 'In Your 20s',
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFEFFAF9),
        tips: [
          'Build emergency fund (3–6 months expenses)',
          'Start investing early—even small amounts compound',
          'Avoid credit card debt at all costs',
          'Get term life insurance if dependents exist',
        ],
      ),
      _AgeGroup(
        icon: Assets.tipsAdviceIcons.icBag,
        age: 'In Your 30s',
        color: const Color(0xFF06B6D4),
        bgColor:   Color(0xFF06B6D4).withValues(alpha: 0.08),
        tips: [
          'Increase emergency fund to 6–12 months',
          'Max out retirement contributions',
          'Start child education fund if applicable',
          'Buy adequate life and health insurance',
        ],
      ),
      _AgeGroup(
        icon: Assets.onboardingIcons.icHome,
        age: 'In Your 40s',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        tips: [
          'Accelerate retirement savings aggressively',
          'Pay off high-interest debts completely',
          'Review and increase insurance coverage',
          'Estate planning and will creation',
        ],
      ),
      _AgeGroup(
        icon: Assets.onboardingIcons.icPersonal,
        age: 'In Your 50s+',
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        tips: [
          'Shift to lower-risk, income-focused investments',
          'Ensure all debts paid before retirement',
          'Maximize retirement contributions (catch-up allowed)',
          'Plan healthcare and long-term care costs',
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
                      'Why Financial Planning Matters',
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
                      'Before Taking a Loan: Essential Steps',
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
                      'Smart Borrowing Strategies',
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
                      'Building & Maintaining Credit Score',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSize.h14),
                    _CreditScoreCard(factors: creditFactors),
                    SizedBox(height: AppSize.h15),
                    Text(
                      'Common Financial Mistakes to Avoid',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSize.h14),
                    ...mistakes.map((m) => _MistakeCard(item: m)),
                    SizedBox(height: AppSize.h15),
                    Text(
                      'Advanced Loan Payment Methods',
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
                      'Setting & Achieving Financial Goals',
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
                      'Should You Invest or Pay Off Debt?',
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
                      'Age-Specific Financial Guidance',
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
                  width: AppSize.sp22,
                  height: AppSize.sp22,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: AppSize.h16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips & Advice',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.themeTextColors.secondaryTextColor,
                          fontSize: AppSize.sp28,
                        ),
                      ),
                      SizedBox(height: AppSize.h6),
                      Text(
                        'Expert financial guidance for success',
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
                      'Build a Secure Future',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: AppSize.h6),
                    Text(
                      'Financial planning helps you achieve life goals, handle emergencies, and build wealth systematically. It\'s not about restricting yourself — it\'s about making informed choices that align with your priorities.',
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
                label: 'Clarity',
              ),
               _StatItem(
                icon: Assets.tipsAdviceIcons.icControl,
                iconColor: const Color(0xFF06B6D4),
                bgColor: const Color(0xFF06B6D4).withValues(alpha: 0.08),
                label: 'Control',
              ),
               _StatItem(
                icon: Assets.onboardingIcons.icStars,
                iconColor: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                label: 'Confidence',
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

  // Returns badge colors based on severity level
  (Color bg, Color text) _severityColors() {
    switch (item.severity) {
      case 'Critical':
        return (const Color(0xFFFEE2E2), const Color(0xFFEF4444));
      case 'High':
        return (const Color(0xFFF1F5F9), const Color(0xFF475569));
      case 'Medium':
        return (const Color(0xFFF1F5F9), const Color(0xFF475569));
      default:
        return (const Color(0xFFF1F5F9), const Color(0xFF475569));
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
                        item.severity,
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
                            text: 'Examples: ',
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
                            text: 'Strategy: ',
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
          title: 'Pay Debt First If:',
          bullets: const [
            'Interest rate is above 12% (credit cards, personal loans)',
            'You\'re paying only minimum dues on credit cards',
            'Debt is causing stress or affecting credit score',
            'No emergency fund exists yet',
          ],
        ),
        SizedBox(height: AppSize.h10),
        _InvestDebtSection(
          icon: Assets.personalLoanIcons.icRightCurcle,
          iconColor: const Color(0xFF22C55E),
          bgColor: const Color(0xFFF0FDF4),
          title: 'Invest Alongside Debt If:',
          bullets: const [
            'Interest rate is below 10% (home loan, education loan)',
            'You have 6-month emergency fund already',
            'Employer matches retirement contributions (free money)',
            'Long investment horizon (15+ years)',
          ],
        ),
        SizedBox(height: AppSize.h10),
        _InvestDebtSection(
          icon: Assets.onboardingIcons.icStars,
          iconColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
          title: 'Best Approach:',
          description:
              'Balance both: Pay extra on high-interest debt while investing consistently in retirement accounts. As debt reduces, shift more toward investing. It\'s not all-or-nothing.',
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
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: AppSize.sp14,
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
                  'Need Personalized Advice?',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: AppSize.h6),
                Text(
                  'Every financial situation is unique. Our certified advisors can create a custom plan for your goals.',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp13,
                    color: const Color(0xFF64748B),
                   ),
                ),
                SizedBox(height: AppSize.h14),
                Row(
                  children: [
                    Text(
                      'Explore Financial Tools',
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
