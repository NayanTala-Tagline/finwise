import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/app_summary_background.dart';
import '../provider/compare_provider.dart';

final _fmt = NumberFormat('#,##,##0', 'en_IN');
String _fmtRs(double v) => '₹${_fmt.format(v.round())}';
String _fmtK(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
  return _fmtRs(v);
}

const _barColors = [
  Color(0xFF2D5BE3),
  Color(0xFF059669),
  Color(0xFF8B5CF6),
  Color(0xFFF59E0B),
];

class CompareResult extends StatelessWidget {
  const CompareResult({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompareProvider>();
    final l10n = context.l10n;
    final bestIdx = provider.bestLoanIndex();
    final results = List.generate(provider.loanCount, provider.resultOf);
    final hasValid = results.any((r) => r.emi > 0);

    if (!hasValid) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Best Loan Card ─────────────────────────────────────────────────
        if (bestIdx >= 0)
          _BestLoanCard(index: bestIdx, result: results[bestIdx]),
        SizedBox(height: AppSize.h16),

        // ── Monthly Payment Comparison ─────────────────────────────────────
        _WhiteCard(
          title: l10n.compareMonthlyPaymentComparison,
          child: _VerticalBarChart(results: results),
        ),
        SizedBox(height: AppSize.h16),



        // ── Detailed Breakdown ─────────────────────────────────────────────
        Text(
          l10n.compareDetailedBreakdown,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSize.h12),
        ...List.generate(results.length, (i) {
          if (results[i].emi == 0) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(bottom: AppSize.h12),
            child: _LoanBreakdownCard(
              index: i,
              result: results[i],
              isBest: i == bestIdx,
            ),
          );
        }),
        SizedBox(height: AppSize.h4),

        // ── Interest Distribution ──────────────────────────────────────────
        _WhiteCard(
          title: l10n.compareInterestDistribution,
          child: _PieChartSection(results: results),
        ),
        SizedBox(height: AppSize.h16),

        Text(
          l10n.compareKeyInsights,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSize.h12),
        _KeyInsightsList(results: results),
        SizedBox(height: AppSize.h12),


        // ── Our Recommendation ─────────────────────────────────────────────
        if (bestIdx >= 0)
          _RecommendationCard(index: bestIdx, result: results[bestIdx]),



      ],
    );
  }
}

// ── Best Loan Card ─────────────────────────────────────────────────────────────

class _BestLoanCard extends StatelessWidget {
  const _BestLoanCard({required this.index, required this.result});

  final int index;
  final LoanResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSummaryBackground(
          gradientColors: const [Color(0xFF059669), Color(0xFF047857)],
          useImage: true,
          imagePath: 'assets/images/splash_screen.png',
          imageOpacity: 0.08,
          imageBlendMode: BlendMode.softLight,
          borderRadius:  BorderRadius.only(topRight: Radius.circular(AppSize.r24),topLeft: Radius.circular(AppSize.r24)),
          child: Padding(
            padding: EdgeInsets.all(AppSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSize.sp8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        Assets.personalLoanIcons.icRecalculateScore.path,
                        width: AppSize.w20,
                        height: AppSize.h20,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(width: AppSize.w10),
                    Expanded(
                      child: Text(
                        context.l10n.compareLoanLabel(index + 1),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: AppSize.sp16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.w10,
                        vertical: AppSize.h4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSize.r5),
                      ),
                      child: Text(
                        context.l10n.compareBestValueBadge,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontSize: AppSize.sp11,
                          fontWeight: FontWeight.w700,
                          color: context.themeTextColors.secondaryTextColor
                         ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h14),

                // Stat chips row
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(label: context.l10n.compareStatChipMonthlyEmi, value: _fmtRs(result.emi)),
                    ),
                    SizedBox(width: AppSize.w8),
                    Expanded(
                      child: _StatChip(label: context.l10n.compareStatChipTotalInterest, value: _fmtRs(result.totalInterest)),
                    ),
                    SizedBox(width: AppSize.w8),
                    Expanded(
                      child: _StatChip(label: context.l10n.fdCalculatorDurationHint, value: context.l10n.compareDurationShort(result.months.round())),
                    ),
                  ],
                ),

                // Description

              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w10,vertical: AppSize.h16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(0, AppSize.sp2),
                blurRadius: AppSize.r5,
              )
            ],
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppSize.r24),bottomRight: Radius.circular(AppSize.r24))
          ),
          child: Center(
            child:  Text(
              context.l10n.compareLowestPayableDesc(_fmtRs(result.totalPayment)),
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: AppSize.sp12,
                color: context.themeTextColors.descriptionColor,
               ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSize.h8,
        horizontal: AppSize.w8,
       ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSize.r10),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.sp12,
                color: Colors.white.withValues(alpha: 0.8),
               ),
              textAlign: TextAlign.center,
             ),
            SizedBox(height: AppSize.h3),
            Text(
              value,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: AppSize.sp14,
                 color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── White Card Wrapper ─────────────────────────────────────────────────────────

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp15,
           ),
        ),
        SizedBox(height: AppSize.h10,),
        Container(
          decoration: BoxDecoration(
            color: context.themeColors.whiteColor,
            borderRadius: BorderRadius.circular(AppSize.r16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(0, AppSize.sp3),
                blurRadius: AppSize.r5,
              )
            ],
          ),
          padding: EdgeInsets.all(AppSize.w16),
          child: Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [


                  child,
                ],
              );
            }
          ),
        ),
      ],
    );
  }
}

// ── Vertical Bar Chart ─────────────────────────────────────────────────────────

class _VerticalBarChart extends StatelessWidget {
  const _VerticalBarChart({required this.results});

  final List<LoanResult> results;

  @override
  Widget build(BuildContext context) {
    final validEMIs = results.map((r) => r.emi).where((v) => v > 0).toList();
    if (validEMIs.isEmpty) return const SizedBox.shrink();

    final maxEmi = validEMIs.fold(0.0, math.max);
    final yMax = _roundUpMax(maxEmi);
    final yStep = yMax / 4;

    final chartHeight = AppSize.h160;
    final barWidth = AppSize.w40;

    return SizedBox(
      height: chartHeight + AppSize.h50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Y-axis labels
          SizedBox(
            width: AppSize.w46,
            height: chartHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (i) {
                final val = yMax - i * yStep;
                return Text(
                  _compactNum(val),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp10,
                    color: context.themeTextColors.descriptionColor,
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: AppSize.w8),

          // Bars + grid
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: chartHeight,
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      results: results,
                      yMax: yMax,
                      colors: _barColors,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(results.length, (i) {
                        if (results[i].emi == 0) {
                          return SizedBox(width: barWidth);
                        }
                        return SizedBox(width: barWidth);
                      }),
                    ),
                  ),
                ),
                SizedBox(height: AppSize.h8),
                // X-axis labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(results.length, (i) {
                    if (results[i].emi == 0) return const SizedBox.shrink();
                    return Text(
                      context.l10n.compareLoanLabel(i + 1),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp11,
                        color: context.themeTextColors.descriptionColor,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _roundUpMax(double v) {
    if (v <= 0) return 20000;
    final magnitude = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    return (v / magnitude).ceil() * magnitude;
  }

  String _compactNum(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).round()}K';
    return v.round().toString();
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.results,
    required this.yMax,
    required this.colors,
  });

  final List<LoanResult> results;
  final double yMax;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;

    // Grid lines (4 lines)
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final validCount = results.where((r) => r.emi > 0).length;
    if (validCount == 0) return;

    final spacing = size.width / (results.length + 1);
    final barWidth = math.min(AppSize.w44, spacing * 0.6);
    final radius = Radius.circular(AppSize.r6);

    for (int i = 0; i < results.length; i++) {
      if (results[i].emi == 0) continue;
      final x = spacing * (i + 1);
      final barH = (results[i].emi / yMax) * size.height;

      final paint = Paint()..color = colors[i % colors.length];
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x - barWidth / 2, size.height - barH, barWidth, barH),
        topLeft: radius,
        topRight: radius,
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.results != results || old.yMax != yMax;
}

// ── Loan Breakdown Card ────────────────────────────────────────────────────────

class _LoanBreakdownCard extends StatelessWidget {
  const _LoanBreakdownCard({
    required this.index,
    required this.result,
    required this.isBest,
  });

  final int index;
  final LoanResult result;
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.07),
            blurRadius: AppSize.r12,
            offset: Offset(0, AppSize.h2),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSize.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: AppSize.w32,
                height: AppSize.h32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _barColors[index % _barColors.length].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp13,
                    fontWeight: FontWeight.w700,
                    color: _barColors[index % _barColors.length],
                  ),
                ),
              ),
              SizedBox(width: AppSize.w10),
              Expanded(
                child: Text(
                  context.l10n.compareLoanLabel(index + 1),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isBest)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.w12,
                    vertical: AppSize.h4,
                  ),
                  decoration: BoxDecoration(
                    color: context.themeColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSize.r8),

                  ),
                  child: Text(
                    context.l10n.compareBestValueBadge,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.sp12,
                      fontWeight: FontWeight.w600,
                      color: context.themeTextColors.textColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSize.h14),

          // ── 2×2 Grid ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _BreakdownCell(
                  label: context.l10n.loanResultMonthlyEmi,
                  value: _fmtRs(result.emi),
                ),
              ),
              SizedBox(width: AppSize.w10),
              Expanded(
                child: _BreakdownCell(
                  label: context.l10n.fdResultTotalInterest,
                  value: _fmtRs(result.totalInterest),
                  valueColor: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h10),
          Row(
            children: [
              Expanded(
                child: _BreakdownCell(
                  label: context.l10n.loanResultTotalPayable,
                  value: _fmtRs(result.totalPayment),
                ),
              ),
              SizedBox(width: AppSize.w10),
              Expanded(
                child: _BreakdownCell(
                  label: context.l10n.fdCalculatorDurationHint,
                  value: context.l10n.compareDurationLong(result.months.round()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownCell extends StatelessWidget {
  const _BreakdownCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppSize.r10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp12,
              color: context.themeTextColors.descriptionColor,
            ),
          ),
          SizedBox(height: AppSize.h4),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? context.themeTextColors.textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Pie Chart Section ──────────────────────────────────────────────────────────

class _PieChartSection extends StatelessWidget {
  const _PieChartSection({required this.results});

  final List<LoanResult> results;

  static const double _chartHeight = 260;
  static const double _labelWidth = 80;

  @override
  Widget build(BuildContext context) {
    final values = results.map((r) => r.totalInterest).toList();
    final total = values.fold(0.0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    final sweeps = <double>[];
    for (final v in values) {
      sweeps.add(v == 0 ? 0.0 : (v / total) * 2 * math.pi);
    }

    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = _chartHeight;
      // Pie radius — leave room for labels on both sides
      final radius = math.min(w / 2, h / 2) - AppSize.h24;
      final cx = w / 2;
      final cy = h / 2;
      final labelR = radius + AppSize.h20;

      final labelWidgets = <Widget>[];
      double angle = -math.pi / 2;
      for (int i = 0; i < results.length; i++) {
        if (results[i].emi == 0 || sweeps[i] == 0) continue;
        final mid = angle + sweeps[i] / 2;
        final lx = cx + labelR * math.cos(mid);
        final ly = cy + labelR * math.sin(mid);
        final label = '${ctx.l10n.compareLoanLabel(i + 1)}: ${_fmtK(results[i].totalInterest)}';

        // Clamp so label stays inside the SizedBox
        final left = (lx - _labelWidth / 2).clamp(0.0, w - _labelWidth);
        final top = (ly - AppSize.h12).clamp(0.0, h - AppSize.h24);

        labelWidgets.add(
          Positioned(
            left: left,
            top: top,
            width: _labelWidth,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: ctx.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.sp11,
                fontWeight: FontWeight.w600,
                color: _barColors[i % _barColors.length],
              ),
            ),
          ),
        );
        angle += sweeps[i];
      }

      return SizedBox(
        height: h,
        width: w,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(w, h),
              painter: _SolidPiePainter(values: values, colors: _barColors),
            ),
            ...labelWidgets,
          ],
        ),
      );
    });
  }
}

class _SolidPiePainter extends CustomPainter {
  const _SolidPiePainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (s, v) => s + v);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - AppSize.h24;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweep = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_SolidPiePainter old) => old.values != values;
}

// ── Key Insights ───────────────────────────────────────────────────────────────

class _KeyInsightsList extends StatelessWidget {
  const _KeyInsightsList({required this.results});

  final List<LoanResult> results;

  @override
  Widget build(BuildContext context) {
    final valid = results.asMap().entries.where((e) => e.value.emi > 0).toList();
    if (valid.isEmpty) return const SizedBox.shrink();

    int lowestEmiIdx = valid.first.key;
    int shortestIdx = valid.first.key;
    int lowestInterestIdx = valid.first.key;

    for (final e in valid) {
      if (e.value.emi < results[lowestEmiIdx].emi) lowestEmiIdx = e.key;
      if (e.value.months < results[shortestIdx].months) shortestIdx = e.key;
      if (e.value.totalInterest < results[lowestInterestIdx].totalInterest) lowestInterestIdx = e.key;
    }

    final l10n = context.l10n;
    final insights = [
      (
        color: const Color(0xFF2D5BE3),
        icon: Assets.onboardingIcons.icCurrency,
        title: l10n.compareLowestMonthlyPayment,
        desc: l10n.compareLowestEmiDesc(_fmtRs(results[lowestEmiIdx].emi), lowestEmiIdx + 1),
      ),
      (
        color: const Color(0xFF059669),
        icon: Assets.personalLoanIcons.icClock,
        title: l10n.compareShortestDuration,
        desc: l10n.compareShortestDurationDesc(results[shortestIdx].months.round(), shortestIdx + 1),
      ),
      (
        color: const Color(0xFF10B981),
        icon: Assets.temperatureIcons.icLowest,
        title: l10n.compareLowestTotalInterest,
        desc: l10n.compareLowestInterestDesc(_fmtRs(results[lowestInterestIdx].totalInterest), lowestInterestIdx + 1),
      ),
    ];

    return Column(
      children: insights
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSize.h10),
              child: Container(
                decoration: BoxDecoration(
                  color: context.themeColors.whiteColor,
                  borderRadius: BorderRadius.circular(AppSize.r16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.06),
                      blurRadius: AppSize.r10,
                      offset: Offset(0, AppSize.h2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w16,
                  vertical: AppSize.h14,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSize.sp12),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        item.icon.path,
                        width: AppSize.w22,
                        height: AppSize.h22,
                        colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(width: AppSize.w14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontSize: AppSize.sp14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: AppSize.h4),
                          Text(
                            item.desc,
                            style: context.textTheme.bodyMedium?.copyWith(
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
            ),
          )
          .toList(),
    );
  }
}

// ── Recommendation Card ────────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.index, required this.result});

  final int index;
  final LoanResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.themeColors;
    final bullets = [
      l10n.compareBullet1,
      l10n.compareBullet2,
      l10n.compareBullet3,
    ];
    return Container(
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.06),
            blurRadius: AppSize.r10,
            offset: Offset(0, AppSize.h2),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSize.w16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.sp10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Assets.personalLoanIcons.icClock.svg( width: AppSize.w22,
              height: AppSize.h22,)
          ),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.compareOurRecommendation,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                SizedBox(height: AppSize.h8),
                Text(
                  l10n.compareRecommendationDesc(index + 1),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.descriptionColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: AppSize.h10),
                ...bullets.map(
                  (b) => Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: AppSize.h5),
                          child: Container(
                            width: AppSize.w5,
                            height: AppSize.h5,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSize.w8),
                        Expanded(
                          child: Text(
                            b,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontSize: AppSize.sp12,
                              color: context.themeTextColors.descriptionColor,
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
          ),
        ],
      ),
    );
  }
}
