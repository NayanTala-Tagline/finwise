import 'package:finwise/features/currency_screen/provider/currency_provider.dart';
import 'package:finwise/features/loan_calculator/widgets/result_row.dart';
import 'package:finwise/features/loan_detail/section_title.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/app_button.dart';

import '../provider/loan_calculator_provider.dart';

class LoanCalculatorResultSheet extends StatelessWidget {
  const LoanCalculatorResultSheet({super.key});

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanCalculatorProvider>();
    final result = provider.result;
    final sym = context.watch<CurrencyProvider>().symbol;
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    return Container(
      margin: EdgeInsets.only(top: AppSize.h80),
      decoration: BoxDecoration(
        color: const Color(0xffFFFAF9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSize.r28),
          topRight: Radius.circular(AppSize.r28),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: AppSize.h12),
          Container(
            width: AppSize.w40,
            height: AppSize.h4,
            decoration: BoxDecoration(
              color: colors.borderColor,
              borderRadius: BorderRadius.circular(AppSize.r2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.w18,
              vertical: AppSize.h8,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Assets.personalLoanIcons.icBack.svg(
                    width: AppSize.w28,
                    height: AppSize.h28,
                    colorFilter: ColorFilter.mode(
                      textColors.textColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Result',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: AppSize.sp20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w28),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSize.w20,
                AppSize.h8,
                AppSize.w20,
                AppSize.h24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(title: 'Loan Information'),
                  SizedBox(height: AppSize.h12),
                  _InfoCard(rows: [
                    ('Loan Amount', '${_fmt(result.loanAmount)}$sym'),
                    ('Down Payment', '${_fmt(result.downPayment)}$sym'),
                    ('Loan Term', '${result.loanTermYears.toStringAsFixed(0)} years'),
                    ('Interest Rate', '${_fmt(result.annualRate)} %'),
                  ]),
                  SizedBox(height: AppSize.h20),
                  SectionTitle(title: 'Result after calculation'),
                  SizedBox(height: AppSize.h12),
                  _InfoCard(rows: [
                    ('Principal Amount', '${_fmt(result.principal)}$sym'),
                    ('Monthly Payment', '${_fmt(result.monthlyPayment)}$sym'),
                    ('Total Interest', '${_fmt(result.totalInterest)}$sym'),
                    ('Total Payment', '${_fmt(result.totalPayment)}$sym'),
                  ]),
                  SizedBox(height: AppSize.h28),
                  AppButton(
                    text: 'Back to Home',
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<(String label, String value)> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffFF8F4A).withValues(alpha: 0.18),
            blurRadius: AppSize.r24,
            spreadRadius: AppSize.sp1,
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++)
            ResultRow(
              label: rows[i].$1,
              value: rows[i].$2,
              showDivider: i != rows.length - 1,
            ),
        ],
      ),
    );
  }
}
