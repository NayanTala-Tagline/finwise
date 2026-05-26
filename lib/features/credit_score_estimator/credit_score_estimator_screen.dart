import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/rate_slider.dart';
import 'provider/credit_score_estimator_provider.dart';

class CreditScoreEstimatorScreen extends StatefulWidget {
  const CreditScoreEstimatorScreen({super.key});

  @override
  State<CreditScoreEstimatorScreen> createState() => _CreditScoreEstimatorScreenState();
}

class _CreditScoreEstimatorScreenState extends State<CreditScoreEstimatorScreen> {
  final PageController _pageController = PageController();
  final CreditScoreEstimatorProvider _provider = CreditScoreEstimatorProvider();
  int _currentStep = 0;
  static const int _totalSteps = 6;

  static double _lastProgress = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0 && _provider.paymentHistory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment history option')),
      );
      return;
    }
    if (_currentStep == 5 && _provider.creditHistoryLength == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your credit history length')),
      );
      return;
    }

    if (_currentStep == _totalSteps - 1) {
      final result = _provider.calculate();
      context.push('/${AppRoutes.creditScoreResult}', extra: result);
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previous() {
    if (_currentStep == 0) {
      if (context.canPop()) context.pop();
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final toProgress = (_currentStep + 1) / _totalSteps;
    final fromProgress = _lastProgress > toProgress ? 0.0 : _lastProgress;
    _lastProgress = toProgress;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: _CreditScoreEstimatorBody(
        pageController: _pageController,
        currentStep: _currentStep,
        totalSteps: _totalSteps,
        fromProgress: fromProgress,
        toProgress: toProgress,
        onNext: _next,
        onPrevious: _previous,
        onPageChanged: (index) => setState(() => _currentStep = index),
      ),
    );
  }
}

class _CreditScoreEstimatorBody extends StatelessWidget {
  const _CreditScoreEstimatorBody({
    required this.pageController,
    required this.currentStep,
    required this.totalSteps,
    required this.fromProgress,
    required this.toProgress,
    required this.onNext,
    required this.onPrevious,
    required this.onPageChanged,
  });

  final PageController pageController;
  final int currentStep;
  final int totalSteps;
  final double fromProgress;
  final double toProgress;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<int> onPageChanged;

  static const List<String> _titles = [
    'Payment History',
    'Account Mix',
    'Credit Limits',
    'Current Balances',
    'Credit Inquiries',
    'Credit History Length',
  ];

  static const List<String> _subtitles = [
    'When was the last negative item on your credit report?',
    'How many of these accounts do you have listed?',
    'Add up all credit limits on your open credit cards',
    'Add up all the most recent statement balances',
    'How many times have you applied for credit in the last 6 months?',
    'When did you first open your oldest active credit or loan account?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      appBar: _CreditEstimatorAppBar(onBack: onPrevious),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSize.h12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w30),
              child: Row(
                children: [
                  Expanded(
                    child: _AnimatedProgress(from: fromProgress, to: toProgress)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 400.ms),
                  ),
                  SizedBox(width: AppSize.w12),
                  Text(
                    '${currentStep + 1} of $totalSteps',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: AppSize.sp12,
                      color: context.themeTextColors.textColor,
                    ),
                  ).animate().fadeIn(duration: 380.ms),
                ],
              ),
            ),
            SizedBox(height: AppSize.h20),
            Text(
              _titles[currentStep],
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: AppSize.sp22,
               ),
            ).animate().fadeIn(delay: 120.ms, duration: 400.ms),
            SizedBox(height: AppSize.h4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: Text(
                _subtitles[currentStep],
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: AppSize.sp14,
                  color: context.themeTextColors.descriptionColor,
                ),
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 400.ms),
            SizedBox(height: AppSize.h16),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _Step1PaymentHistory(),
                  _Step2AccountMix(),
                  _Step3CreditLimits(),
                  _Step4CurrentBalances(),
                  _Step5CreditInquiries(),
                  _Step6HistoryLength(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentStep: currentStep,
        onNext: onNext,
        onPrevious: onPrevious,
        isLastStep: currentStep == totalSteps - 1,
      ),
    );
  }
}

// ─── App Bar ───────────────────────────────────────────────────────────────

class _CreditEstimatorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CreditEstimatorAppBar({required this.onBack});
  final VoidCallback onBack;

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
                  onTap: onBack,
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

// ─── Progress bar ──────────────────────────────────────────────────────────

class _AnimatedProgress extends StatelessWidget {
  const _AnimatedProgress({required this.from, required this.to});
  final double from;
  final double to;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.r6),
      child: SizedBox(
        height: AppSize.h6,
        child: Stack(
          children: [
            Container(color: const Color(0xFFBBC4CE)),
            LayoutBuilder(
              builder: (_, constraints) => TweenAnimationBuilder<double>(
                tween: Tween(begin: from, end: to),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Container(
                  width: constraints.maxWidth * value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.themeColors.primary, const Color(0xFF0D9488)],
                    ),
                    borderRadius: BorderRadius.circular(AppSize.r6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ─────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentStep,
    required this.onNext,
    required this.onPrevious,
    required this.isLastStep,
  });

  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isLastStep;

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
          child: currentStep == 0
              ? AppButton(
                  text: 'Continue',
                  onPressed: onNext,
                  suffixIcon:   Icon(Icons.arrow_forward_ios_sharp, color: Colors.white, size: AppSize.sp18),
                )
              : Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Previous',
                        onPressed: onPrevious,
                        isOutlined: true,
                        prefixIcon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black, size: AppSize.sp18),
                      ),
                    ),
                     Expanded(
                      child: AppButton(
                        text: isLastStep ? 'Calculate' : 'Continue',
                        onPressed: onNext,
                        suffixIcon: Icon(
                      Icons.arrow_forward_ios_sharp,
                          color: Colors.white,
                          size: AppSize.sp18,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// STEP 1 — Payment History
// ═══════════════════════════════════════════════════════════════════════════

class _Step1PaymentHistory extends StatelessWidget {
  const _Step1PaymentHistory();

  static const _options = [
    (PaymentHistory.never, 'Never had a negative item', 'Perfect payment history'),
    (PaymentHistory.moreThan5Years, 'More than 5 years ago', 'Older negative marks'),
    (PaymentHistory.twoToFiveYears, '2-5 years ago', 'Some time has passed'),
    (PaymentHistory.oneToTwoYears, '1-2 years ago', 'Recent history'),
    (PaymentHistory.withinLastYear, 'Within the last year', 'Very recent'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20, vertical: AppSize.h4),
      itemCount: _options.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
      itemBuilder: (_, i) {
        final (value, label, subtitle) = _options[i];
        final selected = provider.paymentHistory == value;
        return _OptionTile(
          label: label,
          subtitle: subtitle,
          selected: selected,
          onTap: () => context.read<CreditScoreEstimatorProvider>().setPaymentHistory(value),
        ).animate().fadeIn(delay: (i * 60).ms, duration: 350.ms).slideX(
              begin: 0.1,
              end: 0,
              delay: (i * 60).ms,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 2 — Account Mix
// ═══════════════════════════════════════════════════════════════════════════

class _Step2AccountMix extends StatelessWidget {
  const _Step2AccountMix();

  static const _items = [
    ('creditCards', 'Credit Cards'),
    ('mortgages', 'Mortgages'),
    ('retailAccounts', 'Retail Accounts'),
    ('autoLoans', 'Auto Loans'),
    ('studentLoans', 'Student Loans'),
    ('otherLoans', 'Other Loans'),
  ];

  int _countFor(CreditScoreEstimatorProvider p, String key) => switch (key) {
        'creditCards' => p.creditCards,
        'mortgages' => p.mortgages,
        'retailAccounts' => p.retailAccounts,
        'autoLoans' => p.autoLoans,
        'studentLoans' => p.studentLoans,
        'otherLoans' => p.otherLoans,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w30, vertical: AppSize.h4),
      itemCount: _items.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
      itemBuilder: (_, i) {
        final (key, label) = _items[i];
        final count = _countFor(provider, key);
        return Padding(
          padding:   EdgeInsets.only(bottom: AppSize.h10),
          child: _CounterTile(
            label: label,
            count: count,
            onDecrement: () => context.read<CreditScoreEstimatorProvider>().setAccountCount(key, -1),
            onIncrement: () => context.read<CreditScoreEstimatorProvider>().setAccountCount(key, 1),
          ).animate().fadeIn(delay: (i * 50).ms, duration: 350.ms),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 3 — Credit Limits
// ═══════════════════════════════════════════════════════════════════════════

class _Step3CreditLimits extends StatelessWidget {
  const _Step3CreditLimits();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final limit = provider.totalCreditLimit;

    return SingleChildScrollView(
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
                  Icon(Icons.info_outline_rounded, color: Color(0xFF0D9488), size: AppSize.sp20),
                SizedBox(width: AppSize.w8),
                Expanded(
                  child: Text(
                    'Include all personal credit cards. Don\'t include business cards or authorized user accounts.',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.sp12,
                      color: context.themeTextColors.descriptionColor
                     ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 4 — Current Balances
// ═══════════════════════════════════════════════════════════════════════════

class _Step4CurrentBalances extends StatefulWidget {
  const _Step4CurrentBalances();

  @override
  State<_Step4CurrentBalances> createState() => _Step4CurrentBalancesState();
}

class _Step4CurrentBalancesState extends State<_Step4CurrentBalances> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final current = context.read<CreditScoreEstimatorProvider>().totalBalance;
    if (current > 0) _controller.text = current.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final utilRate = provider.utilizationRate * 100;
    final isGood = utilRate <= 30;

    return SingleChildScrollView(
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

              ]
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 5 — Credit Inquiries
// ═══════════════════════════════════════════════════════════════════════════

class _Step5CreditInquiries extends StatelessWidget {
  const _Step5CreditInquiries();

  static const _labels = ['None', 'One', 'Times', 'Times', 'Times', 'Times'];
  static const _values = [0, 1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();
    final selected = provider.creditInquiries;

    return SingleChildScrollView(
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
                        spreadRadius: -AppSize.sp3
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_values[i]}',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: AppSize.sp30,
                           color:   context.themeTextColors.textColor,
                        ),
                      ),
                      Text(
                        _labels[i],
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: AppSize.sp12,
                          color:   context.themeTextColors.descriptionColor,
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
                Icon(Icons.info_outline_rounded, color:  context.themeTextColors.primaryTextColor, size: AppSize.sp20),
                SizedBox(width: AppSize.w8),
                Expanded(
                  child: Text(
                    'Multiple inquiries in a short time can lower your score. Try to limit applications.',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: AppSize.sp12,
                      color: context.themeTextColors.descriptionColor
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 360.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 6 — Credit History Length
// ═══════════════════════════════════════════════════════════════════════════

class _Step6HistoryLength extends StatelessWidget {
  const _Step6HistoryLength();

  static const _options = [
    (CreditHistoryLength.moreThan20Years, 'More than 20 years ago', 'Extensive history'),
    (CreditHistoryLength.tenTo20Years, '10-20 years ago', 'Long history'),
    (CreditHistoryLength.fiveTo10Years, '5-10 years ago', 'Established history'),
    (CreditHistoryLength.twoToFiveYears, '2-5 years ago', 'Building history'),
    (CreditHistoryLength.oneToTwoYears, '1-2 years ago', 'Short history'),
    (CreditHistoryLength.lessThan1Year, 'Less than 1 year ago', 'New to credit'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditScoreEstimatorProvider>();

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppSize.w20, ),
            itemCount: _options.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSize.h10),
            itemBuilder: (_, i) {
              final (value, label, subtitle) = _options[i];
              final selected = provider.creditHistoryLength == value;
              return _OptionTile(
                label: label,
                subtitle: subtitle,
                selected: selected,
                onTap: () => context.read<CreditScoreEstimatorProvider>().setCreditHistoryLength(value),
              ).animate().fadeIn(delay: (i * 55).ms, duration: 350.ms).slideX(
                    begin: 0.1,
                    end: 0,
                    delay: (i * 55).ms,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(AppSize.w20, 0, AppSize.w20, AppSize.h12 ,),
          padding: EdgeInsets.all(AppSize.r14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSize.r20),
            border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF16A34A), size: 18),
              SizedBox(width: AppSize.w8),
              Expanded(
                child: Text(
                  'Keep your oldest accounts open even if you don\'t use them often to maintain a longer credit history.',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.sp11,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 380.ms, duration: 400.ms),
      ],
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: AppSize.h58,
        padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.r12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          gradient: selected
              ? LinearGradient(colors: [context.themeColors.primary, const Color(0xFF153885)])
              : const LinearGradient(colors: [Colors.white, Color(0xFFE7F1FF)]),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: AppSize.sp14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : context.themeTextColors.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.sp11,
                      color: selected ? Colors.white70 : context.themeTextColors.descriptionColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: selected
                  ? Icon(Icons.check_circle_rounded, color: Colors.white, size: AppSize.sp20, key: const ValueKey('check'))
                  : SizedBox(width: AppSize.w20, key: const ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.label,
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp16,
               color: context.themeTextColors.textColor,
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.remove,
          onTap: onDecrement,
          enabled: count > 0,
        ),
        SizedBox(width: AppSize.w16),
        SizedBox(
          width: AppSize.w24,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp16,
              fontWeight: FontWeight.w700,
              color: context.themeColors.primary,
            ),
          ),
        ),
        SizedBox(width: AppSize.w16),
        _CounterButton(icon: Icons.add, onTap: onIncrement, enabled: true),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap, required this.enabled});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: AppSize.w28,
        height: AppSize.h28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffE2E8F0))
          // color: enabled ? context.themeColors.primary : const Color(0xFFE2E8F0),
        ),
        child: Icon(icon, size: AppSize.sp16, color: Colors.black),
      ),
    );
  }
}
