import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/gen/assets.gen.dart';
import 'package:finwise/widgets/app_summary_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import 'model/loan_detail_data.dart';

class LoanDetailScreen extends StatefulWidget {
  const LoanDetailScreen({super.key, required this.loanType});

  final LoanType loanType;

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.loanNative;
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
    final data = LoanDetailData.forType(widget.loanType);

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
            _LoanHeader(data: data),
            Expanded(
              child: SingleChildScrollView(
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
                    _SectionHeader(icon: Assets.personalLoanIcons.icInstantApproval.svg(), title: 'Key Features'),
                    SizedBox(height: AppSize.h12),
                    _FeaturesGrid(features: data.features),
                    SizedBox(height: AppSize.h20),
                    _SectionHeader(icon: Assets.homeIcons.icDocuments.svg(), title: 'Common Use Cases'),
                    SizedBox(height: AppSize.h12),
                    _UseCasesCard(useCases: data.useCases),
                    SizedBox(height: AppSize.h20),
                    _SectionHeader(icon:Assets.personalLoanIcons.icClock.svg(), title: 'Application Process'),
                    SizedBox(height: AppSize.h12),
                    _StepsCard(steps: data.steps),
                    SizedBox(height: AppSize.h16),
                    AdSlot(ad: _inlineAd, safeAreaBottom: false, safeAreaTop: false),
                    // SizedBox(height: AppSize.h10),
                    _TrustBadgeCard(),
                    SizedBox(height: AppSize.h8),
                  ],
                ),
              ),
            ),
            _BottomButtons(data: data),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _LoanHeader extends StatelessWidget {
  const _LoanHeader({required this.data});

  final LoanDetailData data;

  @override
  Widget build(BuildContext context) {
    return AppSummaryBackground(

      gradientColors: const [Color(0xFF2563EB), Color(0xFF153885)],
      borderRadius:   BorderRadius.only(
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
                child:   Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: AppSize.sp25),
              ),
              SizedBox(height: AppSize.h16),
              Text(
                data.title,
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: AppSize.sp26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSize.h6),
              Text(
                data.description,
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
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

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

// ── Key Features 2×2 grid ─────────────────────────────────────────────────────

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({required this.features});

  final List<LoanFeature> features;

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
                Expanded(child: _FeatureCard(feature: features[left])),
                SizedBox(width: AppSize.w12),
                Expanded(
                  child: right < features.length
                      ? _FeatureCard(feature: features[right])
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
  const _FeatureCard({required this.feature});

  final LoanFeature feature;

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
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSize.r8),
            ),
            child: Center(
              child: SvgPicture.asset(
                feature.iconPath,
                width: AppSize.w20,
                height: AppSize.h20,
                colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
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

// ── Use Cases card ────────────────────────────────────────────────────────────

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
        children: useCases.map((item) => Padding(
          padding: EdgeInsets.only(bottom: item != useCases.last ? AppSize.h12 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.sp2),
                  decoration: BoxDecoration(shape: BoxShape.circle,color: Color(0xff059669).withValues(alpha: 0.08)),
                  child: Icon(Icons.done, color: const Color(0xFF059669), size: AppSize.sp15)),
              SizedBox(width: AppSize.w10),
              Expanded(
                child: Text(
                  item,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: AppSize.sp14),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

// ── Application Process steps ─────────────────────────────────────────────────

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps});

  final List<LoanStep> steps;

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
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF2563EB),
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

// ── Trust badge ───────────────────────────────────────────────────────────────

class _TrustBadgeCard extends StatelessWidget {
  const _TrustBadgeCard();

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
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_outlined, color: const Color(0xFF22C55E), size: AppSize.sp22),
          ),
          SizedBox(width: AppSize.w14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure & Trusted',
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSize.h4),
                Text(
                  'Your data is protected with bank-level encryption. We never share your information without consent.',
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

// ── Bottom buttons ────────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({required this.data});

  final LoanDetailData data;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                text: 'Calculate',
                backgroundColor: const Color(0xFF2563EB),
                borderRadius: AppSize.r50,
                suffixIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  NavigationHelper().navigateWithAdCheck(context, () {
                    if (data.type == LoanType.creditCard) {
                      context.pushNamed(AppRoutes.creditScoreEstimator);
                    } else {
                      context.pushNamed(AppRoutes.loanCalculator);
                    }
                  });
                },
              ),
               AppButton(
                text: data.processButtonLabel,
                isOutlined: true,
                borderRadius: AppSize.r50,
                onPressed: () {
                  NavigationHelper().navigateWithAdCheck(context, () {
                    context.pushNamed(AppRoutes.loanPurpose);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
