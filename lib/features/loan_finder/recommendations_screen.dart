import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/features/loan_finder/provider/loan_finder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../l10n/app_localizations.dart';
import '../../features/currency_screen/provider/currency_provider.dart';
import '../../gen/assets.gen.dart';
import '../../notification_service/loan_status_notification.dart';
import '../../notification_service/notification_permission_service.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/logger.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_loading_overlay.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_summary_background.dart';
import 'model/loan_finder_result.dart';
import 'widgets/loan_finder_app_bar.dart';
import 'widgets/loan_submitted_dialog.dart';
import 'widgets/rewarded_ad_dialog.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key, required this.result});

  final LoanFinderResult result;

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  /// Cap on how long we wait for the rewarded ad to load before giving up
  /// and letting the user continue without it.
  static const _adLoadTimeout = Duration(seconds: 8);

  /// Cap on how long we wait for the dismiss callback after `show()`.
  static const _dismissTimeout = Duration(seconds: 60);

  FullScreenAdManager? _rewardedAd;
  Completer<void>? _dismissCompleter;
  bool _earnedReward = false;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'recommendations_screen',
    );
    _preloadRewardedAd();
  }

  @override
  void dispose() {
    unawaited(_rewardedAd?.dispose());
    super.dispose();
  }

  /// Kicks off the rewarded-ad load immediately so it's likely ready by the
  /// time the user taps Watch.
  void _preloadRewardedAd() {
    final data = RemoteConfigService.instance.appReward;
    if (!data.enabled || data.adId.isEmpty) return;

    _rewardedAd = FullScreenAdManager(
      adData: data,
      rewardedCallback: FullScreenContentCallback<RewardedAd>(
        onAdDismissedFullScreenContent: (_) => _completeDismiss(),
        onAdFailedToShowFullScreenContent: (_, _) => _completeDismiss(),
      ),
    );
    unawaited(_rewardedAd!.load());
  }

  void _completeDismiss() {
    final c = _dismissCompleter;
    if (c != null && !c.isCompleted) c.complete();
  }

  /// Shows the [AdLoadingOverlay] while the rewarded ad finishes loading, then
  /// plays it. Returns regardless of reward / failure so the caller can keep
  /// the post-ad flow moving (notification permission + success dialog).
  Future<void> _runRewardedAd() async {
    final ad = _rewardedAd;
    if (ad == null) return; // disabled in Remote Config — skip silently

    try {
      // Show loading overlay while ad loads
      AdLoadingOverlay.show(context);

      final status = await ad.future().timeout(
        _adLoadTimeout,
        onTimeout: () => AdStatus.failed,
      );

      // ALWAYS hide overlay after load attempt, before showing ad

      if (!mounted) return;

      if (status != AdStatus.loaded || !ad.isLoaded) return;

      _earnedReward = false;
      _dismissCompleter = Completer<void>();
      // AdLoadingOverlay.hide();

      final shown = await ad.show(
        context: context,
        onUserEarnedReward: (_, _) {
          _earnedReward = true;
        },
      );
      if (shown) {
        await _dismissCompleter!.future.timeout(
          _dismissTimeout,
          onTimeout: () {},
        );
      }
      _dismissCompleter = null;
    } catch (e, s) {
      // Ensure overlay is hidden on any error
      AdLoadingOverlay.hide();
      '❌ rewarded ad failed: $e'.logD;
      s.toString().logD;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final result = widget.result;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: colors.whiteColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Application Summary Card - Fixed at top (non-scrollable)
              _ApplicationSummaryCard(result: result)
                  .animate()
                  .fadeIn(duration: 420.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: -0.15,
                    end: 0,
                    duration: 550.ms,
                    curve: Curves.easeOutCubic,
                  ),
              
              // Scrollable content below
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.w20,
                    AppSize.h16,
                    AppSize.w20,
                    AppSize.h16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DetailsCard(result: result)
                          .animate()
                          .fadeIn(delay: 180.ms, duration: 420.ms)
                          .slideY(
                            begin: 0.18,
                            end: 0,
                            delay: 180.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      SizedBox(height: AppSize.h16),
                      // Estimated Costs Card
                      _EstimatedCostsCard(result: result)
                          .animate()
                          .fadeIn(delay: 280.ms, duration: 420.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 280.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      SizedBox(height: AppSize.h16),
                      const _DisclaimerCard()
                          .animate()
                          .fadeIn(delay: 360.ms, duration: 420.ms)
                          .slideY(
                            begin: 0.25,
                            end: 0,
                            delay: 360.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      offset: Offset(1,0),
                      blurRadius: 2
                  )
                ]
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.w20,
                AppSize.h8,
                AppSize.w20,
                AppSize.h12,
              ),
              child: AppButton(
                text: context.l10n.recommendationsGetButton,
                onPressed: () {
                  AnalyticsManager.instance.logEvent(
                    name: 'recommendations_get_pressed',
                  );
                  RewardedAdDialog.show(
                    context,
                    onWatchAd: () async {
                      AnalyticsManager.instance.logEvent(
                        name: 'recommendations_watch_ad_pressed',
                      );
                      // 1. Play the rewarded ad. AdLoadingOverlay covers the
                      //    load wait; failures / disabled / no fill just
                      //    fall through so the user isn't stuck.
                      await _runRewardedAd();
                      AdLoadingOverlay.hide();

                      if (!context.mounted) return;

                      AnalyticsManager.instance.logEvent(
                        name: 'recommendations_reward_outcome',
                        parameters: {'earned': _earnedReward ? 1 : 0},
                      );

                      // 2. Ask for notification permission. Shows our custom
                      //    request dialog (or settings dialog if permanently
                      //    denied). Granted/already-granted both return true.
                      final granted =
                          await NotificationPermissionService.ensurePermission(
                            context,
                          );
                      if (!context.mounted) return;

                      // 3. Schedule the approval notification only if we'll
                      //    actually be able to deliver it AND the user earned
                      //    the reward (skipped ads → no scheduled approval).
                      if (granted && _earnedReward) {
                        await LoanStatusNotification.scheduleApproval(
                          amount: result.loanAmount,
                        );
                      }
                      if (!context.mounted) return;

                      // 4. Always show the success dialog so the user sees
                      //    confirmation regardless of permission state.

                      await LoanSubmittedDialog.show(context);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Application Summary Card ──────────────────────────────────────────────

class _ApplicationSummaryCard extends StatelessWidget {
  const _ApplicationSummaryCard({required this.result});

  final LoanFinderResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    
    // Calculate eligibility score
    final l10n = context.l10n;
    final eligibilityScore = _calculateEligibilityScore();
    final scoreColor = _getScoreColor(eligibilityScore);
    final scoreLabel = _getScoreLabel(eligibilityScore, l10n);

    return AppSummaryBackground(
      backgroundColor: colors.primary,
      gradientColors: [
        colors.primary.withValues(alpha: 0.8),
        const Color(0xff153885).withValues(alpha: 0.7),
      ],
      useImage: true,
      imagePath: Assets.images.splashScreen.path,
      imageOpacity: 0.3,
      imageBlendMode: BlendMode.hardLight,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(AppSize.r24),
        bottomLeft: Radius.circular(AppSize.r24),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back button and title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => NavigationHelper().handleBackPress(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: AppSize.sp20,
                  ),
                ),
                Flexible(
                  child: Text(
                    context.l10n.recommendationsAppSummary,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: AppSize.sp16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w20),
              ],
            ),
            SizedBox(height: AppSize.h16),
            SizedBox(height: AppSize.h12),
            Container(
              padding: EdgeInsets.all(AppSize.w16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSize.r16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.recommendationsEligibilityScore,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: textColors.descriptionColor,
                              fontSize: AppSize.sp13,
                            ),
                          ),
                          SizedBox(height: AppSize.h4),
                          Text(
                            scoreLabel,
                            style: context.textTheme.titleLarge?.copyWith(
                              color: scoreColor,
                              fontSize: AppSize.sp24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSize.w12,
                          vertical: AppSize.h6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(AppSize.r8),
                        ),
                        child: Text(
                          '${eligibilityScore.toStringAsFixed(0)}%',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: AppSize.sp12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSize.r4),
                    child: LinearProgressIndicator(
                      value: eligibilityScore / 100,
                      minHeight: AppSize.h8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateEligibilityScore() {
    double score = 50.0;
    switch (result.creditScore) {
      case CreditScoreRange.excellent:
        score += 30;
        break;
      case CreditScoreRange.good:
        score += 20;
        break;
      case CreditScoreRange.fair:
        score += 10;
        break;
      case CreditScoreRange.poor:
        score += 0;
        break;
      case CreditScoreRange.dontKnow:
        score += 15;
        break;
    }
    if (!result.hasExistingLoans) {
      score += 10;
    } else if (result.numberOfLoans != null && result.numberOfLoans! > 3) {
      score -= 20;
    }
    final ratio = result.monthlyIncome / result.loanAmount;
    if (ratio > 0.5) score += 10;
    else if (ratio > 0.3) score += 5;
    return score.clamp(0, 100);
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return const Color(0xFF10B981);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getScoreLabel(double score, AppLocalizations l10n) {
    if (score >= 70) return l10n.tipsSeverityHigh;
    if (score >= 40) return l10n.tipsSeverityMedium;
    return l10n.recommendationsLow;
  }
}

// ── Estimated Costs Card ──────────────────────────────────────────────────

class _EstimatedCostsCard extends StatelessWidget {
  const _EstimatedCostsCard({required this.result});

  final LoanFinderResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    final sym = context.watch<CurrencyProvider>().symbol;

    final loanAmount = result.loanAmount;
    const processingFee = 0;
    final totalAmount = loanAmount + processingFee;

    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: Offset(0, 3),
            blurRadius: AppSize.r3,
          ),
        ],
        border: Border.all(
          color: colors.borderColor2.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.recommendationsEstimatedCosts,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSize.h16),
          _CostRow(
            label: context.l10n.loanCalculatorLoanAmount,
            value: '$sym${loanAmount.toInt()}',
            textColors: textColors,
          ),
          Divider(height: AppSize.h20, thickness: 1, color: Color(0xffE2E8F0)),
          _CostRow(
            label: context.l10n.recommendationsProcessingFee,
            value: '$sym$processingFee',
            textColors: textColors,
          ),
          SizedBox(height: AppSize.h12),
          Divider(height: AppSize.h0, thickness: 1, color: Color(0xffE2E8F0)),
          _CostRow(
            label: context.l10n.recommendationsTotalAmount,
            value: '$sym${totalAmount.toInt()}',
            textColors: textColors,
            isTotal: true,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    required this.textColors,
    this.isTotal = false,
    this.colors,
  });

  final String label;
  final String value;
  final dynamic textColors;
  final bool isTotal;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isTotal
          ? EdgeInsets.symmetric(
              horizontal: AppSize.w12,
              vertical: AppSize.h10,
            )
          : EdgeInsets.zero,
      decoration: isTotal
          ? BoxDecoration(
              color: const Color(0xFFEFF6FF), // Light blue background
              borderRadius: BorderRadius. only(bottomLeft: Radius.circular(AppSize.r12),bottomRight: Radius.circular(AppSize.r12)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: isTotal ? textColors.textColor : textColors.descriptionColor,
              fontSize: AppSize.sp14,
            ),
          ),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: isTotal ? colors?.primary : textColors.textColor,
              fontSize: AppSize.sp14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary header (peach card with clipboard illustration) ───────────────

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w14,
        vertical: AppSize.h14,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
          ),
        ],
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        border: Border.all(color: colors.borderColor2, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Assets.loanFinder.icLoanDetails.svg(
          //   width: AppSize.w110,
          //   height: AppSize.h90,
          // ),
          SizedBox(width: AppSize.w10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Assets.loanFinder.icDone.svg(
                    //   width: AppSize.w20,
                    //   height: AppSize.h20,
                    // ),
                    SizedBox(width: AppSize.w6),
                    Expanded(
                      child: Text(
                        context.l10n.recommendationsInfoSummary,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: textColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: AppSize.sp14,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h6),
                Text(
                  context.l10n.recommendationsInfoSummaryDesc,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textColors.descriptionColor,
                    fontSize: AppSize.sp10,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
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

// ── Details card ─────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.result});

  final LoanFinderResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final l10n = context.l10n;
    final sym = context.watch<CurrencyProvider>().symbol;

    final rows = <_DetailRow>[
      _DetailRow(
        label: l10n.recommendationsLoanPurpose,
        value: result.purpose.label(l10n),
        isFirst: true,
      ),
      _DetailRow(
        label: l10n.loanCalculatorLoanAmount,
        value: '$sym${result.loanAmount.toInt()}',
      ),
      _DetailRow(
        label: l10n.recommendationsMonthlyIncome,
        value: '$sym${result.monthlyIncome.toInt()}',
      ),
      _DetailRow(
        label: l10n.recommendationsEmployment,
        value: result.employmentStatus.label(l10n),
      ),
      _DetailRow(label: l10n.recommendationsCreditScore, value: result.creditScore.label(l10n)),
      _DetailRow(
        label: l10n.recommendationsExistingLoans,
        value: result.existingLoansDisplay(l10n),
      ),
      _DetailRow(label: l10n.recommendationsUrgency, value: result.urgency.label(l10n)),
      // _DetailRow(
      //    label: 'Processing Fee',
      //   value: '00',
      //   highlight: true,
      // ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w14,
        vertical: AppSize.h12,
      ),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1),offset: Offset(0,3) ,blurRadius: AppSize.r3),
        ],
        border: Border.all(
          color: colors.borderColor2.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.recommendationsYourInfo,style: context.textTheme.titleMedium?.copyWith(fontSize: AppSize.sp15),),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Color(0xffE2E8F0),

              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isFirst = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    final isLast = highlight;

    return Container(
      padding: EdgeInsets.symmetric(

        vertical: AppSize.h12,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? colors.secondary2.withValues(alpha: 0.35)
            : Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(AppSize.r16) : Radius.zero,
          bottom: isLast ? Radius.circular(AppSize.r16) : Radius.zero,
        ),
      ),
      child: Row(

        children: [
           Expanded(
            flex: 5,
            child: Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                color: textColors.textColor,
                fontWeight: FontWeight.w500,
                fontSize: AppSize.sp13,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: context.textTheme.titleSmall?.copyWith(
              color: textColors.textColor,
              fontWeight: FontWeight.w600,
              fontSize: AppSize.sp13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Disclaimer card ──────────────────────────────────────────────────────

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final borderRadius = BorderRadius.circular(AppSize.r12);

    return Container(
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1),offset: Offset(0,3) ,blurRadius: AppSize.r3),
        ],
        border: Border.all(
          color: colors.borderColor2.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSize.w14,
            AppSize.h12,
            AppSize.w14,
            AppSize.h14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(context.l10n.recommendationsWhatNext,style: context.textTheme.titleMedium?.copyWith(fontSize: AppSize.sp15),),
               SizedBox(height: AppSize.h10),

               _DisclaimerLine(
                text: context.l10n.recommendationsNextStep1,
              icon: Assets.temperatureIcons.icLowest.svg(colorFilter: ColorFilter.mode(context.themeColors.primary,  BlendMode.srcIn,)),
                iconBgColor: context.themeColors.primary.withValues(alpha: 0.1),
              ),
              SizedBox(height: AppSize.h10),
              _DisclaimerLine(
                icon: Assets.personalLoanIcons.icClock.svg(colorFilter: ColorFilter.mode(Color(0xff0D9488),  BlendMode.srcIn,)),
                iconBgColor: context.themeColors.primary.withValues(alpha: 0.1),
                text: context.l10n.recommendationsNextStep2,
              ),SizedBox(height: AppSize.h10),
              _DisclaimerLine(
                icon: Assets.onboardingIcons.icVerification.svg(colorFilter: ColorFilter.mode(Color(0xff059669),  BlendMode.srcIn,),width: AppSize.w14,height: AppSize.h18),
                iconBgColor: context.themeColors.primary.withValues(alpha: 0.1),
                text: context.l10n.recommendationsNextStep3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisclaimerLine extends StatelessWidget {
  const _DisclaimerLine({required this.text, required this.iconBgColor, required this.icon});

  final String text;
  final Color iconBgColor;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
       children: [
        Container(
          margin: EdgeInsets.only(top: AppSize.h3),
          padding: EdgeInsets.all(AppSize.sp10),
           decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child:  icon
        ),
        SizedBox(width: AppSize.w8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.titleMedium?.copyWith(
               fontSize: AppSize.sp14,
              ),
          ),
        ),
      ],
    );
  }
}