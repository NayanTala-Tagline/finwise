import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../widgets/ad_slot.dart';
import 'provider/credit_score_ad_provider.dart';
import 'provider/credit_score_estimator_provider.dart';
import 'widgets/credit_score_layout.dart';

class Step5CreditInquiriesScreen extends StatefulWidget {
  const Step5CreditInquiriesScreen({super.key, this.inlineAd});

  final InlineAdManager? inlineAd;

  @override
  State<Step5CreditInquiriesScreen> createState() => _Step5CreditInquiriesScreenState();
}

class _Step5CreditInquiriesScreenState extends State<Step5CreditInquiriesScreen> {
  static const _values = [0, 1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'credit_score_step5_screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreditScoreAdProvider>().preloadAfterStep(4);
    });
  }

  @override
  void dispose() {
    unawaited(widget.inlineAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.creditScoreStep5InquiryNone,
      l10n.creditScoreStep5InquiryOne,
      l10n.creditScoreStep5InquiryTimes,
      l10n.creditScoreStep5InquiryTimes,
      l10n.creditScoreStep5InquiryTimes,
      l10n.creditScoreStep5InquiryTimes,
    ];
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final adProvider = context.watch<CreditScoreAdProvider>();
    final selected = provider.creditInquiries;

    return CreditScoreLayout(
      stepIndex: 4,
      title: l10n.creditScoreStep5Title,
      subtitle: l10n.creditScoreStep5Question,
      isLoading: adProvider.busy,
      adSlot: AdSlot(ad: widget.inlineAd),
      onNextPressed: () => context.read<CreditScoreAdProvider>().next(context, AppRoutes.creditScoreStep6),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSize.w20,
                mainAxisSpacing: AppSize.h20,
                childAspectRatio: 1.5,
              ),
              itemCount: _values.length,
              itemBuilder: (_, i) {
                final isSelected = selected == _values[i];
                return GestureDetector(
                  onTap: () => context.read<CreditScoreEstimatorProvider>().setCreditInquiries(_values[i]),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.r24),
                      color: isSelected ? context.themeColors.primary.withValues(alpha: 0.04) : Colors.white,
                      border: isSelected ? Border.all(color: context.themeColors.primary) : null,
                      boxShadow: [
                        BoxShadow(
                          color: context.themeColors.primary.withValues(alpha: 0.1),
                          offset: Offset(0, AppSize.sp10),
                          blurRadius: AppSize.r15,
                          spreadRadius: -AppSize.sp3,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_values[i]}',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontSize: AppSize.sp30,
                            color: context.themeTextColors.textColor,
                          ),
                        ),
                        Text(
                          labels[i],
                          style: context.textTheme.titleMedium?.copyWith(
                            fontSize: AppSize.sp12,
                            color: context.themeTextColors.descriptionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (i * 60).ms, duration: 350.ms).scale(
                      begin: const Offset(0.85, 0.85),
                      delay: (i * 60).ms,
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    );
              },
            ),
            SizedBox(height: AppSize.h16),
            Container(
              padding: EdgeInsets.all(AppSize.r14),
              decoration: BoxDecoration(
                color: context.themeColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSize.r12),
                border: Border.all(color: context.themeColors.primary),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: context.themeTextColors.primaryTextColor, size: AppSize.sp20),
                  SizedBox(width: AppSize.w8),
                  Expanded(
                    child: Text(
                      l10n.creditScoreStep5Tip,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp12,
                        color: context.themeTextColors.descriptionColor,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 360.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
