import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/features/currency_screen/provider/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/app_summary_background.dart';
import '../../widgets/common_appbar.dart';
import 'package:go_router/go_router.dart';
import 'provider/loan_calculator_provider.dart';

class LoanCalculatorScreen extends StatelessWidget {
  const LoanCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoanCalculatorProvider(),
      child: const _LoanCalculatorView(),
    );
  }
}

class _LoanCalculatorView extends StatefulWidget {
  const _LoanCalculatorView();

  @override
  State<_LoanCalculatorView> createState() => _LoanCalculatorViewState();
}

class _LoanCalculatorViewState extends State<_LoanCalculatorView> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
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

  void _calculate(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    final provider = context.read<LoanCalculatorProvider>();
    if (!provider.isInputValid) {
      'Please enter valid values.'.showErrorAlert();
      return;
    }
    provider.calculate();
  }

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<LoanCalculatorProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) provider.setStartDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanCalculatorProvider>();
    final currencySymbol = context.watch<CurrencyProvider>().symbol;
    final textColors = context.themeTextColors;
    final isResult = provider.isCalculated;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isResult) {
          provider.refresh();
        } else {
          NavigationHelper().handleBackPress(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: CommonAppBar(
          titleText: 'Loan Calculator',
          titleTextStyle: context.textTheme.bodyMedium?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w700,
          ),
          leading: GestureDetector(
            onTap: () {
              if (isResult) {
                provider.refresh();
              } else {
                NavigationHelper().handleBackPress(context);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSize.h6),
              child: Center(
                child: Assets.personalLoanIcons.icBack.svg(
                  width: AppSize.w24,
                  height: AppSize.h24,
                  colorFilter: ColorFilter.mode(textColors.textColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
        body: isResult
            ? _ResultView(result: provider.result, inlineAd: _inlineAd)
            : _FormView(
                provider: provider,
                currencySymbol: currencySymbol,
                onPickDate: () => _pickDate(context),
              ),
        bottomNavigationBar: isResult
            ? _ResultBottomBar(onReset: provider.refresh)
            : _FormBottomBar(onCalculate: () => _calculate(context)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// FORM VIEW
// ═══════════════════════════════════════════════════════════════════════

class _FormView extends StatelessWidget {
  const _FormView({
    required this.provider,
    required this.currencySymbol,
    required this.onPickDate,
  });

  final LoanCalculatorProvider provider;
  final String currencySymbol;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final textColors = context.themeTextColors;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20, vertical: AppSize.h20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: 'Loan Amount'),
          SizedBox(height: AppSize.h8),
          AppTextFormField(
            controller: provider.loanAmountController,
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            onChanged: (_) {},
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: AppSize.w16),
              child: Text(
                currencySymbol,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp16,
                  fontWeight: FontWeight.w500,
                  color: textColors.descriptionColor,
                ),
              ),
            ),
            suffixIconConstraints: BoxConstraints(minWidth: AppSize.w30, minHeight: 0),
          ),
          SizedBox(height: AppSize.h20),
          _InterestRateCard(rate: provider.interestRate, onChanged: provider.setInterestRate),
          SizedBox(height: AppSize.h20),
          _FieldLabel(label: 'Loan Term'),
          SizedBox(height: AppSize.h8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AppTextFormField(
                  controller: provider.loanTermController,
                  hintText: '',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                  onChanged: (_) {},
                ),
              ),
              SizedBox(width: AppSize.w10),
              Expanded(
                flex: 2,
                child: AppTextFormField(
                  hintText: 'Months',
                  dropdownItems: const ['Months', 'Years'],
                  dropdownValue: provider.termUnit,
                  onDropdownChanged: (v) => provider.setTermUnit(v ?? 'Months'),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h20),
          _FieldLabel(label: 'Loan Start Date'),
          SizedBox(height: AppSize.h8),
          GestureDetector(
            onTap: onPickDate,
            child: AbsorbPointer(
              child: AppTextFormField(
                controller: provider.startDateController,
                hintText: '',
                onChanged: (_) {},
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: AppSize.w14),
                  child: Icon(Icons.calendar_month_outlined,
                      size: AppSize.sp22, color: textColors.descriptionColor),
                ),
                suffixIconConstraints: BoxConstraints(minWidth: AppSize.w36, minHeight: 0),
              ),
            ),
          ),
          SizedBox(height: AppSize.h8),
        ],
      ),
    );
  }
}

class _FormBottomBar extends StatelessWidget {
  const _FormBottomBar({required this.onCalculate});
  final VoidCallback onCalculate;

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
          padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h12, AppSize.w20, AppSize.h16),
          child: AppButton(
            text: 'Calculate Now',
            backgroundColor: const Color(0xFF2563EB),
            borderRadius: AppSize.r50,
            onPressed: onCalculate,
          ),
        ),
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
          SizedBox(height: AppSize.h16),
          AdSlot(ad: inlineAd, safeAreaBottom: false, safeAreaTop: false),
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
          padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h12, AppSize.w20, AppSize.h16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: 'Loan Application Steps',
                backgroundColor: const Color(0xFF2563EB),
                borderRadius: AppSize.r50,
                suffixIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  NavigationHelper().navigateWithAdCheck(context, () {
                    context.pushNamed(AppRoutes.loanPurpose);
                  });
                },
              ),
              SizedBox(height: AppSize.h10),
              AppButton(
                text: 'Reset',
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
        borderRadius: BorderRadius.only(topRight: Radius.circular(AppSize.r20),topLeft: Radius.circular(AppSize.r20)),
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
                      'Result',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSize.sp12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<LoanCalculatorProvider>().refresh(),
                    child: Assets.personalLoanIcons.icRestart.svg(fit: BoxFit.contain)
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Monthly EMI',
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
                'per month',
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
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppSize.r16),bottomRight: Radius.circular(AppSize.r16)),
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
                      label: 'Principal Amount',
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
                      label: 'Total Interest',
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
                  'Total Payable',
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
                'Payment Breakdown',
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700,fontSize: AppSize.sp16),
              ),
            ],
          ),
          SizedBox(height: AppSize.h24),
          Center(
            child: SizedBox(
              width: AppSize.w160,
              height: AppSize.h160,
              child: CustomPaint(
                painter: _DonutPainter(principal: result.principal, interest: result.totalInterest),
              ),
            ),
          ),
          SizedBox(height: AppSize.h20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF2563EB), label: 'Principal', value: '₹${_fmtRupee(result.principal)}'),
              SizedBox(width: AppSize.w24),
              _LegendDot(color: const Color(0xFFFFA726), label: 'Interest', value: '₹${_fmtRupee(result.totalInterest)}'),
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
            Text(label, style: context.textTheme.bodySmall?.copyWith(
              color: context.themeTextColors.descriptionColor,
              fontSize: AppSize.sp12,
            )),
          ],
        ),
        SizedBox(height: AppSize.h2),
        Text(value, style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: AppSize.sp13,
        )),
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
    final xLabels = milestones.map((m) => m == totalMonths ? 'End' : 'M$m').toList();

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
            'Growth Timeline',
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700,fontSize: AppSize.sp16),
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
    for (final p in pts) { fillPath.lineTo(p.dx, p.dy); }
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
  bool shouldRepaint(_LineChartPainter old) =>
      old.points != points;
}

// ═══════════════════════════════════════════════════════════════════════
// SHARED FORM WIDGETS
// ═══════════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _InterestRateCard extends StatelessWidget {
  const _InterestRateCard({required this.rate, required this.onChanged});

  final double rate;
  final ValueChanged<double> onChanged;

  static const double _min = 8.0;
  static const double _max = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h18, AppSize.w20, AppSize.h16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 16, spreadRadius: 0, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interest Rate', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: AppSize.sp16)),
              Text('${rate.toStringAsFixed(1)}%', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: AppSize.sp16, color: const Color(0xFF2563EB))),
            ],
          ),
          SizedBox(height: AppSize.h16),
          _RateSlider(value: rate, min: _min, max: _max, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _RateSlider extends StatelessWidget {
  const _RateSlider({required this.value, required this.min, required this.max, required this.onChanged});

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2563EB);
    final t = max == min ? 0.0 : ((value - min) / (max - min)).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final pos = t * w;

      void emit(double localX) {
        final newT = (localX / w).clamp(0.0, 1.0);
        onChanged(double.parse((min + newT * (max - min)).toStringAsFixed(1)));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => emit(d.localPosition.dx),
            onPanUpdate: (d) => emit(d.localPosition.dx),
            child: SizedBox(
              height: AppSize.h24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(left: 0, right: 0, top: AppSize.h9,
                    child: Container(height: AppSize.h6, decoration: BoxDecoration(color: const Color(0xFFE8EAED), borderRadius: BorderRadius.circular(AppSize.r4)))),
                  Positioned(left: 0, top: AppSize.h9,
                    child: Container(width: pos, height: AppSize.h6, decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(AppSize.r4)))),
                  Positioned(left: pos - AppSize.w12, top: 0,
                    child: Container(
                      width: AppSize.w24, height: AppSize.h24,
                      decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Color(0x402563EB), blurRadius: 8, offset: Offset(0, 2))]),
                    )),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSize.h8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('8%', style: context.textTheme.bodySmall?.copyWith(color: context.themeTextColors.descriptionColor, fontSize: AppSize.sp13)),
              Text('20%', style: context.textTheme.bodySmall?.copyWith(color: context.themeTextColors.descriptionColor, fontSize: AppSize.sp13)),
            ],
          ),
        ],
      );
    });
  }
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
