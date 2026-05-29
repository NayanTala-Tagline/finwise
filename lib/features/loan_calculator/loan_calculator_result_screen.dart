import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_summary_background.dart';
import '../../widgets/common_appbar.dart';
import 'provider/loan_calculator_provider.dart';

class LoanCalculatorResultScreen extends StatefulWidget {
  const LoanCalculatorResultScreen({super.key});

  @override
  State<LoanCalculatorResultScreen> createState() => _LoanCalculatorResultScreenState();
}

class _LoanCalculatorResultScreenState extends State<LoanCalculatorResultScreen> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'loan_calculator_result_screen');
    _loadAd();
  }

  void _loadAd() {
    final data = RemoteConfigService.instance.loanCalculatorResultNative;
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
    final provider = context.watch<LoanCalculatorProvider>();
    final textColors = context.themeTextColors;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: CommonAppBar(
        titleText: context.l10n.loanResultTitle,
        titleTextStyle: context.textTheme.bodyMedium?.copyWith(
          fontSize: AppSize.sp18,
          fontWeight: FontWeight.w700,
        ),
        leading: GestureDetector(
          onTap: () {
            NavigationHelper().navigateWithAdCheck(context, () {
              context.pop();
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSize.h6),
            child: Center(
              child: Assets.personalLoanIcons.icBack.svg(
                width: AppSize.w26,
                height: AppSize.h26,
                colorFilter: ColorFilter.mode(textColors.textColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
      body: _ResultView(result: provider.result, inlineAd: _inlineAd),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdSlot(ad: _inlineAd, safeAreaBottom: false, safeAreaTop: false),
          _ResultBottomBar(
            onReset: () {
              NavigationHelper().navigateWithAdCheck(context, () {
                 context.pop();
              });
             },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// RESULT VIEW
// ═══════════════════════════════════════════════════════════════════════

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.inlineAd});

  final LoanCalculatorResult result;
  final InlineAdManager? inlineAd;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h16),
      child: Column(
        children: [
          Column(
            children: [
              _HeroEmiCard(result: result),
              _SummaryCard(result: result),
            ],
          ),
          SizedBox(height: AppSize.h16),
          _PaymentBreakdownCard(result: result),
          SizedBox(height: AppSize.h16),
          _GrowthTimelineCard(result: result),
           SizedBox(height: AppSize.h8),
        ],
      ),
    );
  }
}

class _ResultBottomBar extends StatelessWidget {
  const _ResultBottomBar({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h12, AppSize.w20, AppSize.h0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: context.l10n.loanResultApplicationSteps,
                backgroundColor: const Color(0xFF2563EB),
                borderRadius: AppSize.r50,
                suffixIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  NavigationHelper().navigateWithAdCheck(context, () {
                    context.pushNamed(AppRoutes.loanPurpose);
                  });
                },
              ),
              AppButton(
                text: context.l10n.fdReset,
                isOutlined: true,
                borderRadius: AppSize.r50,
                onPressed: onReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero EMI card ─────────────────────────────────────────────────────────────

class _HeroEmiCard extends StatelessWidget {
  const _HeroEmiCard({required this.result});
  final LoanCalculatorResult result;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.h166,
      child: AppSummaryBackground(
        gradientColors: const [Color(0xFF1A55C4), Color(0xFF3B82F6)],
        useImage: true,
        imagePath: 'assets/images/splash_screen.png',
        backgroundColor: const Color(0xFF2563EB),
        imageOpacity: 0.35,
        imageBlendMode: BlendMode.screen,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppSize.r20),
          topLeft: Radius.circular(AppSize.r20),
        ),
        child: SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h16, AppSize.w20, AppSize.h18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.w10,
                        vertical: AppSize.h4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(AppSize.r6),
                      ),
                      child: Text(
                        context.l10n.fdResult,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: AppSize.sp12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        NavigationHelper().navigateWithAdCheck(context, () {
                          context.pop();
                        });
                      },
                      child: Assets.personalLoanIcons.icRestart.svg(fit: BoxFit.contain),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  context.l10n.loanResultMonthlyEmi,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: AppSize.sp14,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  '₹${_fmtRupee(result.monthlyPayment)}',
                  style: context.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: AppSize.sp40,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  context.l10n.loanResultPerMonth,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: AppSize.sp12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});
  final LoanCalculatorResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSize.r16),
          bottomRight: Radius.circular(AppSize.r16),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.w14,
                      vertical: AppSize.h14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(AppSize.r18),
                    ),
                    child: _SummaryItem(
                      label: context.l10n.fdResultPrincipalAmount,
                      value: '₹${_fmtRupee(result.principal)}',
                      valueColor: context.themeTextColors.textColor,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.w14,
                      vertical: AppSize.h14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(AppSize.r18),
                    ),
                    child: _SummaryItem(
                      label: context.l10n.fdResultTotalInterest,
                      value: '₹${_fmtRupee(result.totalInterest)}',
                      valueColor: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.h16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h18),
            decoration: BoxDecoration(
              color: context.themeColors.primary.withValues(alpha: 0.05),
              border: Border.all(color: context.themeColors.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(AppSize.r18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.loanResultTotalPayable,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '₹${_fmtRupee(result.totalPayment)}',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
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

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value, required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.themeTextColors.descriptionColor,
            fontSize: AppSize.sp12,
          ),
        ),
        SizedBox(height: AppSize.h4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
            fontSize: AppSize.sp15,
          ),
        ),
      ],
    );
  }
}

// ── Payment breakdown donut ───────────────────────────────────────────────────

class _PaymentBreakdownCard extends StatelessWidget {
  const _PaymentBreakdownCard({required this.result});
  final LoanCalculatorResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Assets.personalLoanIcons.icPaymentBreakdown.svg(),
              SizedBox(width: AppSize.w8),
              Text(
                context.l10n.fdResultPaymentBreakdown,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSize.sp16,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h24),
          Center(
            child: SizedBox(
              width: AppSize.w160,
              height: AppSize.h160,
              child: CustomPaint(
                painter: _DonutPainter(
                  principal: result.principal,
                  interest: result.totalInterest,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSize.h20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: const Color(0xFF2563EB),
                label: context.l10n.loanResultPrincipal,
                value: '₹${_fmtRupee(result.principal)}',
              ),
              SizedBox(width: AppSize.w24),
              _LegendDot(
                color: const Color(0xFFFFA726),
                label: context.l10n.loanResultInterest,
                value: '₹${_fmtRupee(result.totalInterest)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: AppSize.w10,
              height: AppSize.h10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            SizedBox(width: AppSize.w6),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.themeTextColors.descriptionColor,
                fontSize: AppSize.sp12,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.h2),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: AppSize.sp13,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.principal, required this.interest});
  final double principal;
  final double interest;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.40;
    final arcRadius = radius - strokeWidth / 2;
    final total = principal + interest;
    if (total == 0) return;

    final principalSweep = (principal / total) * 2 * math.pi;
    final interestSweep = (interest / total) * 2 * math.pi;
    const gap = 0.05;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF2563EB);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      -math.pi / 2,
      principalSweep - gap,
      false,
      paint,
    );

    paint.color = const Color(0xFFFFA726);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      -math.pi / 2 + principalSweep,
      interestSweep - gap,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.principal != principal || old.interest != interest;
}

// ── Growth timeline chart ─────────────────────────────────────────────────────

class _GrowthTimelineCard extends StatelessWidget {
  const _GrowthTimelineCard({required this.result});
  final LoanCalculatorResult result;

  @override
  Widget build(BuildContext context) {
    final totalMonths = (result.loanTermYears * 12).round().clamp(1, 999);
    final emi = result.monthlyPayment;
    final totalPay = result.totalPayment;

    final milestones = _buildMilestones(totalMonths);
    final points = milestones.map((m) => (m * emi) / totalPay).toList();
    final xLabels = milestones.map((m) => m == totalMonths ? context.l10n.fdResultTimelineEnd : 'M$m').toList();

    final maxVal = totalPay;
    final yLabels = List.generate(5, (i) => maxVal * (i + 1) / 5);

    return Container(
      padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.fdResultGrowthTimeline,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: AppSize.sp16,
            ),
          ),
          SizedBox(height: AppSize.h16),
          SizedBox(
            height: AppSize.h160,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(
                points: points,
                xLabels: xLabels,
                yLabels: yLabels.map(_shortLabel).toList(),
                lineColor: const Color(0xFF2563EB),
                fillColorTop: const Color(0x402563EB),
                fillColorBottom: const Color(0x002563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> _buildMilestones(int n) {
    if (n <= 6) return List.generate(n, (i) => i + 1);
    final step = n ~/ 5;
    return [step, step * 2, step * 3, step * 4, n];
  }

  String _shortLabel(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(0)}Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(0)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.points,
    required this.xLabels,
    required this.yLabels,
    required this.lineColor,
    required this.fillColorTop,
    required this.fillColorBottom,
  });

  final List<double> points;
  final List<String> xLabels;
  final List<String> yLabels;
  final Color lineColor;
  final Color fillColorTop;
  final Color fillColorBottom;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPad = 36.0;
    const bottomPad = 22.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    final n = points.length;
    final pts = List.generate(n, (i) {
      final x = leftPad + (n == 1 ? 0.5 : i / (n - 1)) * chartW;
      final y = chartH * (1.0 - points[i].clamp(0.0, 1.0));
      return Offset(x, y);
    });

    // Grid lines (Y)
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = chartH * i / 4;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    // Y-axis labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < yLabels.length; i++) {
      final y = chartH * (1 - (i + 1) / yLabels.length);
      tp.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E)),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // X-axis labels
    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPad + (n == 1 ? 0.5 : i / (n - 1)) * chartW;
      tp.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E)),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
    }

    // Area fill
    final fillPath = Path()..moveTo(pts.first.dx, chartH);
    for (final p in pts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(pts.last.dx, chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, chartH),
          [fillColorTop, fillColorBottom],
        ),
    );

    // Line
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = lineColor
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    for (final p in pts) {
      canvas.drawCircle(p, 3.5, Paint()..color = lineColor);
      canvas.drawCircle(p, 2.0, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.points != points;
}

// ═══════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════

String _fmtRupee(double v) {
  final n = v.round();
  if (n < 1000) return n.toString();
  final s = n.toString();
  final last3 = s.substring(s.length - 3);
  var rem = s.substring(0, s.length - 3);
  final groups = <String>[];
  while (rem.length > 2) {
    groups.insert(0, rem.substring(rem.length - 2));
    rem = rem.substring(0, rem.length - 2);
  }
  groups.insert(0, rem);
  return '${groups.join(',')},${last3.toString()}';
}
