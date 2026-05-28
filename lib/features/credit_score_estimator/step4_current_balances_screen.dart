import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_textfield.dart';
import 'provider/credit_score_ad_provider.dart';
import 'provider/credit_score_estimator_provider.dart';
import 'widgets/credit_score_layout.dart';

class Step4CurrentBalancesScreen extends StatefulWidget {
  const Step4CurrentBalancesScreen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Step4CurrentBalancesScreen> createState() => _Step4CurrentBalancesScreenState();
}

class _Step4CurrentBalancesScreenState extends State<Step4CurrentBalancesScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final current = context.read<CreditScoreEstimatorProvider>().totalBalance;
    if (current > 0) _controller.text = current.toStringAsFixed(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreditScoreAdProvider>().preloadAfterStep(3);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final adProvider = context.watch<CreditScoreAdProvider>();
    final utilRate = provider.utilizationRate * 100;
    final isGood = utilRate <= 30;

    return CreditScoreLayout(
      stepIndex: 3,
      title: 'Current Balances',
      subtitle: 'Add up all the most recent statement balances',
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: () => context.read<CreditScoreAdProvider>().next(context, AppRoutes.creditScoreStep5),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextFormField(
              title: 'Total Balance',
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hintText: '0',
              prefix: Text(
                '₹',
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: AppSize.sp18,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColors.textColor,
                ),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val?.replaceAll(',', '') ?? '') ?? 0;
                context.read<CreditScoreEstimatorProvider>().setTotalBalance(parsed);
              },
            ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
            SizedBox(height: AppSize.h16),
            Container(
              padding: EdgeInsets.all(AppSize.r16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSize.r16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff000000).withValues(alpha: 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: AppSize.r15,
                    spreadRadius: -AppSize.sp2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credit Utilization',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontSize: AppSize.sp14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${utilRate.toStringAsFixed(0)}%',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontSize: AppSize.sp14,
                          fontWeight: FontWeight.w700,
                          color: isGood ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSize.r4),
                    child: LinearProgressIndicator(
                      value: provider.utilizationRate.clamp(0.0, 1.0),
                      minHeight: AppSize.h8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation(
                        isGood ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSize.h10),
                  Text(
                    'Aim for under 30% for best results',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.sp12,
                      color: context.themeTextColors.descriptionColor,
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
