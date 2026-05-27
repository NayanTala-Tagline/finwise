import 'dart:math' as math;

import 'package:finwise/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_summary_background.dart';
import 'provider/credit_score_estimator_provider.dart';

class CreditScoreResultScreen extends StatelessWidget {
  const CreditScoreResultScreen({super.key, required this.result});

  final CreditScoreResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      appBar: _ResultAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h16, AppSize.w16, AppSize.h100),
        child: Column(
          children: [
            _ScoreCard(result: result).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
            Container(
              padding: EdgeInsets.symmetric(vertical: AppSize.h20,horizontal: AppSize.w20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff000000).withValues(alpha: 0.1),
                    blurRadius: AppSize.r6,
                    spreadRadius: AppSize.sp5,
                  ),
                ],
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(AppSize.r20),bottomLeft: Radius.circular(AppSize.r20))
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ScoreStat(
                      label: 'Utilization',
                      value: '${result.utilization.toStringAsFixed(0)}%',
                    ),
                  ),
                  SizedBox(width: AppSize.w20),
                  Expanded(
                    child: _ScoreStat(
                      label: 'Total Accounts',
                      value: '${result.totalAccounts}',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.h16),
            _ScoreFactorsCard(result: result).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 600.ms, curve: Curves.easeOutCubic),

            SizedBox(height: AppSize.h16),
            _FactorDistributionCard(result: result).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 600.ms, curve: Curves.easeOutCubic),
            SizedBox(height: AppSize.h16),
            _ImprovementTipsCard(result: result).animate().fadeIn(delay: 420.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, delay: 420.ms, duration: 600.ms, curve: Curves.easeOutCubic),
            SizedBox(height: AppSize.h12),
            _DisclaimerText().animate().fadeIn(delay: 500.ms, duration: 400.ms),

           ],
        ),
      ),
      bottomNavigationBar: _BottomButtons(
        onRecalculate: () => context.pop(),
        onTips: () => context.push('/${AppRoutes.tipsAdvice}'),
      ),
    );
  }
}

// ─── AppBar ────────────────────────────────────────────────────────────────

class _ResultAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(AppSize.h56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2)],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSize.h56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: AppSize.w12,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.arrow_back_ios, size: AppSize.sp22, color: Colors.black),
                ),
              ),
              Text(
                'Credit Score Estimator',
                style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.sp18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Score Card ────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});
  final CreditScoreResult result;

  @override
  Widget build(BuildContext context) {
    return AppSummaryBackground(
      gradientColors: const [Color(0xFFF59E0B), Color(0xFFF59E0B)],
      borderRadius: BorderRadius.only(topLeft: Radius.circular(AppSize.r26),topRight: Radius.circular(AppSize.r26)),
      useImage: true,
      imagePath: 'assets/images/splash_screen.png',
      imageOpacity: 0.8,
      backgroundColor: Color(0xFFF59E0B),
      child: Padding(
        padding: EdgeInsets.all(AppSize.r20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w10, vertical: AppSize.h4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppSize.r5),
                  ),
                  child: Text(
                    'Estimated Credit Score',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: AppSize.sp13,
                      color: Colors.white,
                     ),
                  ),
                ),
                const Spacer(),
                GestureDetector(onTap: () => context.pop(),child: Assets.personalLoanIcons.icRestart.svg(fit: BoxFit.contain))


              ],
            ),
            SizedBox(height: AppSize.h12),

                Text(
                  '${result.score}',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: AppSize.sp60,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),

            Text(
              result.grade,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: AppSize.sp18,
                 color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: AppSize.h16),
            _ScoreProgressBar(score: result.score),

          ],
        ),
      ),
    );
  }
}

class _ScoreProgressBar extends StatelessWidget {
  const _ScoreProgressBar({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final progress = ((score - 300) / 600).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('300', style: TextStyle(color: Colors.white70, fontSize: AppSize.sp12)),
            Text('600', style: TextStyle(color: Colors.white70, fontSize: AppSize.sp12)),
            Text('700', style: TextStyle(color: Colors.white70, fontSize: AppSize.sp12)),
            Text('900', style: TextStyle(color: Colors.white70, fontSize: AppSize.sp12)),
          ],
        ),
        SizedBox(height: AppSize.h10),
        LayoutBuilder(
          builder: (_, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: AppSize.h8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppSize.r4),
                ),
              ),
              Container(
                height: AppSize.h8,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSize.r4),
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20,vertical: AppSize.h20),
      decoration: BoxDecoration(
        color: Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(AppSize.r24)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.sp12),
          ),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp30,
             ),
          ),
        ],
      ),
    );
  }
}

// ─── Score Factors Card ────────────────────────────────────────────────────

class _ScoreFactorsCard extends StatelessWidget {
  const _ScoreFactorsCard({required this.result});
  final CreditScoreResult result;

  @override
  Widget build(BuildContext context) {
    final factors = [
      _FactorData('Payment History', 'High Impact', result.paymentHistoryScore, const Color(0xFF16A34A)),
      _FactorData('Credit Utilization', 'High Impact', result.creditUtilizationScore, const Color(0xFF2563EB)),
      _FactorData('Credit Age', 'Medium Impact', result.creditAgeScore, const Color(0xFF7C3AED)),
      _FactorData('Account Mix', 'Medium Impact', result.accountMixScore, const Color(0xFFF59E0B)),
      _FactorData('Credit Inquiries', 'Low Impact', result.creditInquiriesScore, const Color(0xFFDC2626)),
    ];

    return Container(
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
            children: [
              Icon(Icons.bar_chart_rounded, color: context.themeColors.primary, size: AppSize.sp22),
              SizedBox(width: AppSize.w8),
              Text(
                'Score Factors',
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h16),
          ...factors.asMap().entries.map((entry) {
            return _FactorRow(data: entry.value)
                .animate()
                .fadeIn(delay: (entry.key * 80).ms, duration: 400.ms)
                .slideX(begin: 0.1, end: 0, delay: (entry.key * 80).ms, duration: 450.ms, curve: Curves.easeOutCubic);
          }),
        ],
      ),
    );
  }
}

class _FactorData {
  const _FactorData(this.name, this.impact, this.score, this.color);
  final String name;
  final String impact;
  final double score;
  final Color color;
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.data});
  final _FactorData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.h14),
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
                    data.name,
                    style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.sp13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    data.impact,
                    style: context.textTheme.bodySmall?.copyWith(fontSize: AppSize.sp11, color: context.themeTextColors.descriptionColor),
                  ),
                ],
              ),
              Text(
                '${(data.score * 100).toStringAsFixed(0)}%',
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp14,
                  fontWeight: FontWeight.w700,
                  color: data.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: data.score),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.r4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: AppSize.h6,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation(data.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Factor Distribution (Donut Chart) ────────────────────────────────────

class _FactorDistributionCard extends StatelessWidget {
  const _FactorDistributionCard({required this.result});
  final CreditScoreResult result;

  @override
  Widget build(BuildContext context) {
    final segments = [
      _DonutSegment('Payment History', result.paymentHistoryScore * 0.35, const Color(0xFF16A34A)),
      _DonutSegment('Credit Utilization', result.creditUtilizationScore * 0.30, const Color(0xFF06B6D4)),
      _DonutSegment('Credit Age', result.creditAgeScore * 0.15, const Color(0xFF7C3AED)),
      _DonutSegment('Credit Inquiries', result.creditInquiriesScore * 0.10, const Color(0xFFDC2626)),
      _DonutSegment('Account Mix', result.accountMixScore * 0.10, const Color(0xFFF59E0B)),
    ];

    return Container(
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
            children: [
              Icon(Icons.pie_chart_rounded, color: context.themeColors.primary, size: AppSize.sp22),
              SizedBox(width: AppSize.w8),
              Text(
                'Factor Distribution',
                style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.sp16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: AppSize.h20),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, progress, _) => SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _DonutChartPainter(segments: segments, animationProgress: progress),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSize.h20),
          Column(
            children: List.generate(
              (segments.length / 2).ceil(),
              (rowIdx) {
                final left = rowIdx * 2;
                final right = left + 1;
                return Padding(
                  padding: EdgeInsets.only(top: rowIdx > 0 ? AppSize.h10 : 0),
                  child: Row(
                    children: [
                      Expanded(child: _LegendItem(label: segments[left].label, color: segments[left].color)),
                      if (right < segments.length)
                        Expanded(child: _LegendItem(label: segments[right].label, color: segments[right].color))
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.segments, required this.animationProgress});
  final List<_DonutSegment> segments;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.35;

    double startAngle = -math.pi / 2;
    const gap = 0.06;

    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * math.pi * animationProgress;
      if (sweepAngle <= gap) continue;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + gap / 2,
        sweepAngle - gap,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.animationProgress != animationProgress;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSize.w10,
          height: AppSize.h10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSize.w6),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: AppSize.sp11,
            color: context.themeTextColors.descriptionColor,
          ),
        ),
      ],
    );
  }
}

// ─── Improvement Tips ─────────────────────────────────────────────────────

class _ImprovementTipsCard extends StatelessWidget {
  const _ImprovementTipsCard({required this.result});
  final CreditScoreResult result;

  List<_TipData> _buildTips() {
    final tips = <_TipData>[];

    if (result.creditUtilizationScore < 0.8) {
      tips.add(const _TipData(
        icon: Icons.credit_card_off_rounded,
        iconColor: Color(0xFFDC2626),
        title: 'Reduce Credit Utilization',
        description: 'Keep balances below 30% of your total credit limit',
        badge: 'High Priority',
        badgeColor: Color(0xFF2563EB),
      ));
    }

    tips.add(const _TipData(
      icon: Icons.checklist_rounded,
      iconColor: Color(0xFF0D9488),
      title: 'Make On-Time Payments',
      description: 'Payment history is the most important factor',
      badge: 'Maintain',
      badgeColor: Color(0xFF2563EB),
    ));

    if (result.creditInquiriesScore < 0.8) {
      tips.add(const _TipData(
        icon: Icons.check_circle_outline_rounded,
        iconColor: Color(0xFF16A34A),
        title: 'Limit Credit Applications',
        description: 'Too many inquiries can lower your score',
        badge: 'Good',
        badgeColor: Color(0xFF16A34A),
      ));
    }

    if (result.accountMixScore < 0.7) {
      tips.add(const _TipData(
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFF0284C7),
        title: 'Diversify Account Types',
        description: 'Mix of credit cards, loans, and mortgages helps',
        badge: 'Consider',
        badgeColor: Color(0xFF1E40AF),
      ));
    }

    return tips.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tips = _buildTips();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tips_and_updates_rounded, color: context.themeColors.primary, size: AppSize.sp22),
            SizedBox(width: AppSize.w8),
            Text(
              'Improvement Tips',
              style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.sp16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: AppSize.h12),
        ...tips.asMap().entries.map(
          (entry) => _TipCard(tip: entry.value)
              .animate()
              .fadeIn(delay: (entry.key * 80).ms, duration: 400.ms)
              .slideX(begin: 0.08, end: 0, delay: (entry.key * 80).ms, duration: 450.ms),
        ),
      ],
    );
  }
}

class _TipData {
  const _TipData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String badge;
  final Color badgeColor;
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});
  final _TipData tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.h12),
      padding: EdgeInsets.all(AppSize.r16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.w50,
            height: AppSize.h50,
            decoration: BoxDecoration(
              color: tip.iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(tip.icon, color: tip.iconColor, size: AppSize.sp24),
          ),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        tip.title,
                        style: context.textTheme.titleSmall?.copyWith(fontSize: AppSize.sp14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: AppSize.w8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSize.w8, vertical: AppSize.h3),
                      decoration: BoxDecoration(
                        color: context.themeColors.primary,
                        borderRadius: BorderRadius.circular(AppSize.r6),
                      ),
                      child: Text(
                        tip.badge,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: AppSize.sp10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h6),
                Text(
                  tip.description,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp11,
                    color: context.themeTextColors.descriptionColor,
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

// ─── Ad Banner ─────────────────────────────────────────────────────────────

class _AdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.h80,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppSize.r12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          'AD',
          style: context.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFCBD5E1),
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ─── Disclaimer ────────────────────────────────────────────────────────────

class _DisclaimerText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w4),
      child: Text(
        'This is an estimated score based on the information you provided. Your actual credit score may vary. For your official credit report, contact authorized credit bureaus.',
        textAlign: TextAlign.center,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: AppSize.sp11,
          color: context.themeTextColors.descriptionColor,
        ),
      ),
    );
  }
}

// ─── Bottom Buttons ────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({required this.onRecalculate, required this.onTips});
  final VoidCallback onRecalculate;
  final VoidCallback onTips;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x26000000), offset: Offset(0, -1), blurRadius: 4)],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h10, AppSize.w20, AppSize.h0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: 'Recalculate Score',
                onPressed: onRecalculate,
                prefixIcon: const Icon(Icons.person_search_rounded, color: Colors.white, size: 18),
              ),
               AppButton(
                text: 'View More Financial Tips',
                onPressed: onTips,
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
