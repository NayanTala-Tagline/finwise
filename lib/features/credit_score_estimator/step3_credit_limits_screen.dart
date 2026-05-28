import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/rate_slider.dart';
import 'provider/credit_score_ad_provider.dart';
import 'provider/credit_score_estimator_provider.dart';
import 'widgets/credit_score_layout.dart';

class Step3CreditLimitsScreen extends StatefulWidget {
  const Step3CreditLimitsScreen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Step3CreditLimitsScreen> createState() => _Step3CreditLimitsScreenState();
}

class _Step3CreditLimitsScreenState extends State<Step3CreditLimitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreditScoreAdProvider>().preloadAfterStep(2);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final adProvider = context.watch<CreditScoreAdProvider>();
    final limit = provider.totalCreditLimit;

    return CreditScoreLayout(
      stepIndex: 2,
      title: 'Credit Limits',
      subtitle: 'Add up all credit limits on your open credit cards',
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: () => context.read<CreditScoreAdProvider>().next(context, AppRoutes.creditScoreStep4),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppSize.r16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSize.r16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Credit Limit',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: AppSize.sp15,
                        ),
                      ),
                      Text(
                        '₹${limit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: AppSize.sp16,
                          color: context.themeColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h16),
                  RateSlider(
                    value: limit,
                    min: 10000,
                    max: 2000000,
                    divisions: 199,
                    minLabel: '₹10K',
                    maxLabel: '₹20L',
                    onChanged: (v) => context.read<CreditScoreEstimatorProvider>().setCreditLimit(v),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
            SizedBox(height: AppSize.h16),
            Container(
              padding: EdgeInsets.all(AppSize.r14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.r20),
                border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: const Color(0xFF0D9488), size: AppSize.sp20),
                  SizedBox(width: AppSize.w8),
                  Expanded(
                    child: Text(
                      'Include all personal credit cards. Don\'t include business cards or authorized user accounts.',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: AppSize.sp12,
                        color: context.themeTextColors.descriptionColor,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
