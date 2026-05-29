import 'dart:async';
import 'dart:math' as math;

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../extension/ext_context.dart';
import '../../currency_screen/provider/currency_provider.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_size.dart';
import '../../../utils/remote_config.dart';
import '../../../widgets/ad_slot.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/common_appbar.dart';
import '../provider/fixed_deposit_provider.dart';

class FdResultSheet extends StatefulWidget {
  const FdResultSheet({super.key});

  @override
  State<FdResultSheet> createState() => _FdResultSheetState();
}

class _FdResultSheetState extends State<FdResultSheet> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.fixedDepositResultNative;
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
    final provider = context.watch<FixedDepositProvider>();
    final result = provider.result;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CommonAppBar(
        titleText: context.l10n.fdResultTitle,
        onBackPress: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h24),
              child: Column(
                children: [
                  _SummaryCard(result: result, onRefresh: () {
                    provider.refresh();
                    Navigator.of(context).pop();
                  }),
                  SizedBox(height: AppSize.h16),
                  _PaymentBreakdownCard(
                    principal: result.principal,
                    interest: result.totalInterestValue,
                  ),
                  SizedBox(height: AppSize.h16),
                  _GrowthTimelineCard(result: result),

                ],
              ),
            ),
          ),
          AdSlot(ad: _inlineAd, safeAreaBottom: false),
          // ── Bottom Buttons ─────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x26000000), offset: Offset(0, -1), blurRadius: 4)],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h8, AppSize.w16, AppSize.h0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: context.l10n.fdViewStepsButton,
                      borderRadius: AppSize.r50,
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/FixedDepositScreen'),
                    ),
                    AppButton(
                      text: context.l10n.fdReset,
                      isOutlined: true,
                      borderRadius: AppSize.r50,
                      onPressed: () {
                        provider.refresh();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Header ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result, required this.onRefresh});

  final FdResult result;
  final VoidCallback onRefresh;

  static final _fmt = NumberFormat('#,##,##0', 'en_IN');
  String _fmtAmt(double v, String sym) => '$sym${_fmt.format(v.round())}';

  @override
  Widget build(BuildContext context) {
    final primary = context.themeColors.primary;
    final sym = context.watch<CurrencyProvider>().symbol;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.r20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Green top section ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, Color.lerp(primary, Colors.black, 0.1)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSize.w12, vertical: AppSize.h4),
                        decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(AppSize.r8),
                            color: Colors.white.withValues(alpha: 0.2)
                        ),
                        child: Text(
                          context.l10n.fdResult,
                          style: context.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      GestureDetector(
                        onTap: onRefresh,
                        child: Assets.personalLoanIcons.icRestart.svg(
                          width: AppSize.w22,
                          height: AppSize.h22,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h16),
                  Text(
                    context.l10n.fdResultMaturityAmount,
                    style: context.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: AppSize.sp13),
                  ),
                  SizedBox(height: AppSize.h4),
                  Text(
                    _fmtAmt(result.maturityValue, sym),
                    style: context.textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, height: 1.1),
                  ),
                  SizedBox(height: AppSize.h4),
                  Text(
                    context.l10n.fdResultAtMaturity,
                    style: context.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            // ── White bottom section ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w12, vertical: AppSize.h12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSize.r10),
                     ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.fdResultPrincipalAmount, style: context.textTheme.bodyLarge?.copyWith(color: context.themeTextColors.descriptionColor,  fontSize: AppSize.sp12)),
                        SizedBox(height: AppSize.h4),
                        Text(_fmtAmt(result.principal, sym), style: context.textTheme.titleSmall?.copyWith( fontSize: AppSize.sp16)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w12, vertical: AppSize.h12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSize.r10),
                     ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.fdResultTotalInterest, style: context.textTheme.bodyLarge?.copyWith(color: context.themeTextColors.descriptionColor, fontSize: AppSize.sp12)),
                        SizedBox(height: AppSize.h4),
                        Text(_fmtAmt(result.totalInterestValue, sym), style: context.textTheme.titleSmall?.copyWith(color: primary,  fontSize: AppSize.sp16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Breakdown ───────────────────────────────────────────────────────────

class _PaymentBreakdownCard extends StatelessWidget {
  const _PaymentBreakdownCard({required this.principal, required this.interest});
  final double principal;
  final double interest;

  static final _fmt = NumberFormat('#,##,##0', 'en_IN');
  String _fmtAmt(double v, String sym) => '$sym${_fmt.format(v.round())}';

  @override
  Widget build(BuildContext context) {
    final primary = context.themeColors.primary;
    final sym = context.watch<CurrencyProvider>().symbol;
    final interestColor = Color.lerp(primary, Colors.white, 0.55)!;

    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.w28,
                height: AppSize.h28,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Assets.personalLoanIcons.icPaymentBreakdown.svg(
                  width: AppSize.w16, height: AppSize.h16,
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                ),
              ),
              SizedBox(width: AppSize.w8),
              Text(context.l10n.fdResultPaymentBreakdown, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: AppSize.sp15)),
            ],
          ),
          SizedBox(height: AppSize.h16),
          SizedBox(
            height: AppSize.h200,
            width: double.infinity,
            child: CustomPaint(
              painter: _DonutPainter(
                principal: principal,
                interest: interest,
                investmentColor: primary,
                interestColor: interestColor,
              ),
            ),
          ),
          SizedBox(height: AppSize.h16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: primary, label: context.l10n.fdResultInvestmentLegend, value: _fmtAmt(principal, sym)),
              SizedBox(width: AppSize.w24),
              _LegendItem(color: interestColor, label: context.l10n.loanResultInterest, value: _fmtAmt(interest, sym)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: AppSize.w8, height: AppSize.h8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: AppSize.w6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: AppSize.sp11)),
            Text(value, style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: AppSize.sp12)),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.principal, required this.interest, required this.investmentColor, required this.interestColor});
  final double principal;
  final double interest;
  final Color investmentColor;
  final Color interestColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = principal + interest;
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.75;
    final strokeWidth = radius * 0.42;
    const gap = 0.06;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final investSweep = (principal / total) * 2 * math.pi;
    final interestSweep = (interest / total) * 2 * math.pi;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.butt;
    paint.color = investmentColor;
    canvas.drawArc(rect, start, investSweep - gap, false, paint);
    paint.color = interestColor;
    canvas.drawArc(rect, start + investSweep, interestSweep - gap, false, paint);
  }

  @override
  bool shouldRepaint(_DonutPainter o) => o.principal != principal || o.interest != interest;
}

// ── Growth Timeline ─────────────────────────────────────────────────────────────

class _GrowthTimelineCard extends StatelessWidget {
  const _GrowthTimelineCard({required this.result});
  final FdResult result;

  static const int _pts = 7;

  List<double> get _values => List.generate(_pts, (i) {
        final m = result.tenureMonths * i / (_pts - 1);
        return result.principal + result.principal * result.annualRate / 100 * m / 12;
      });

  List<String> _xLabels(BuildContext context) {
    final l10n = context.l10n;
    final labels = <String>[l10n.fdResultTimelineStart];
    for (int i = 1; i < _pts - 1; i++) {
      final m = (result.tenureMonths * i / (_pts - 1)).round();
      labels.add(result.tenureMonths > 24 ? 'Y${(m / 12).round()}' : 'M$m');
    }
    labels.add(l10n.fdResultTimelineEnd);
    return labels;
  }

  double get _niceMax {
    final v = result.maturityValue * 1.1;
    if (v <= 0) return 100000;
    final mag = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    final step = mag / 10;
    return (v / step).ceil() * step;
  }

  String _yLabel(double v) {
    if (v == 0) return '0';
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final vals = _values;
    final labels = _xLabels(context);
    final maxY = _niceMax;
    final yTicks = List.generate(5, (i) => maxY * (4 - i) / 4);
    final primary = context.themeColors.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.w28,
                height: AppSize.h28,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(
                  child: Assets.homeIcons.icFdCalculator.svg(
                    width: AppSize.w16, height: AppSize.h16,
                    colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w8),
              Text(context.l10n.fdResultGrowthTimeline, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: AppSize.sp15)),
            ],
          ),
          SizedBox(height: AppSize.h16),
          SizedBox(
            height: AppSize.h180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: AppSize.w48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: yTicks
                        .map((v) => Padding(
                              padding: EdgeInsets.only(right: AppSize.w6),
                              child: Text(_yLabel(v), style: context.textTheme.bodySmall?.copyWith(color: Colors.black38, fontSize: AppSize.sp10)),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: _GrowthPainter(values: vals, maxY: maxY, lineColor: primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.h6),
          Padding(
            padding: EdgeInsets.only(left: AppSize.w48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((l) => Text(l, style: context.textTheme.bodySmall?.copyWith(color: Colors.black38, fontSize: AppSize.sp10))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthPainter extends CustomPainter {
  const _GrowthPainter({required this.values, required this.maxY, required this.lineColor});
  final List<double> values;
  final double maxY;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || maxY <= 0) return;
    final n = values.length;
    final xStep = size.width / (n - 1);
    double px(int i) => i * xStep;
    double py(double v) => size.height * (1 - v / maxY);

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        Paint()..color = const Color(0xFFEEEEEE)..strokeWidth = 1,
      );
    }

    // Area fill
    final areaPath = Path()..moveTo(px(0), size.height);
    for (int i = 0; i < n; i++) { areaPath.lineTo(px(i), py(values[i])); }
    areaPath.lineTo(px(n - 1), size.height);
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withValues(alpha: 0.25), lineColor.withValues(alpha: 0.04)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(px(0), py(values[0]));
    for (int i = 1; i < n; i++) { linePath.lineTo(px(i), py(values[i])); }
    canvas.drawPath(
      linePath,
      Paint()..color = lineColor..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_GrowthPainter o) => o.values != values || o.maxY != maxY;
}
