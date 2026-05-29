import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/app_textfield.dart';
import '../../../widgets/rate_slider.dart';
import '../provider/compare_provider.dart';

class LoanCard extends StatefulWidget {
  const LoanCard({
    super.key,
    required this.index,
    this.onDelete,
  });

  final int index;
  final VoidCallback? onDelete;

  @override
  State<LoanCard> createState() => _LoanCardState();
}

class _LoanCardState extends State<LoanCard> {
  late final TextEditingController _amountController;
  late final TextEditingController _tenureController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CompareProvider>();
    _amountController = TextEditingController(text: provider.amountOf(widget.index));
    _tenureController = TextEditingController(text: provider.tenureOf(widget.index));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _syncFromProvider(CompareProvider provider) {
    final amount = provider.amountOf(widget.index);
    if (_amountController.text != amount) _amountController.text = amount;
    final tenure = provider.tenureOf(widget.index);
    if (_tenureController.text != tenure) _tenureController.text = tenure;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final l10n = context.l10n;
    final provider = context.watch<CompareProvider>();
    _syncFromProvider(provider);

    final tenureUnit = provider.tenureUnitOf(widget.index);
    final rate = provider.rateOf(widget.index);
    final num = widget.index + 1;

    return Container(
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.08),
            blurRadius: AppSize.r12,
            offset: Offset(0, AppSize.h2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(AppSize.w14, AppSize.h12, AppSize.w14, AppSize.h12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSize.sp12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.082),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$num',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: colors.primary,
                       fontSize: AppSize.sp14,
                     ),
                  ),
                ),
                SizedBox(width: AppSize.w10),
                Expanded(
                  child: Text(
                    l10n.compareLoanLabel(num),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: AppSize.sp15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onDelete != null)
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Icon(
                      Icons.delete_outline_outlined,
                      color: context.themeTextColors.descriptionColor,
                      size: AppSize.sp20,
                    ),
                  ),
              ],
            ),
          ),

          // ── Loan Amount ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(AppSize.w14, AppSize.h0, AppSize.w14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.loanCalculatorLoanAmount,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp13,
                   ),
                ),
                SizedBox(height: AppSize.h6),
                AppTextFormField(
                  controller: _amountController,
                  hintText: l10n.compareCardLoanAmountHint,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => provider.setAmount(widget.index, v ?? ''),
                ),
              ],
            ),
          ),

          // ── Loan Term ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(AppSize.w14, AppSize.h12, AppSize.w14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.loanCalculatorLoanTerm,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp13,
                  ),
                ),
                SizedBox(height: AppSize.h6),
                Row(
                  children: [
                    Expanded(
                       child: AppTextFormField(
                        controller: _tenureController,
                        hintText: l10n.compareCardDurationHint,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) => provider.setTenure(widget.index, v ?? ''),
                      ),
                    ),
                     Expanded(
                        child: AppTextFormField(
                          dropdownItems: [l10n.compareCardMonth, l10n.compareCardYear],
                           contentHeight: AppSize.h12,
                          dropdownValue: tenureUnit == TenureUnit.month ? l10n.compareCardMonth : l10n.compareCardYear,
                            onDropdownChanged: (v) {
                            provider.setTenureUnit(
                              widget.index,
                              v == l10n.compareCardYear ? TenureUnit.year : TenureUnit.month,
                            );
                          },
                        ),
                     ),
                  ],
                ),
              ],
            ),
          ),

          // ── Interest Rate ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(AppSize.w14, AppSize.h14, AppSize.w14, AppSize.h16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.fdCalculatorInterestRate,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp13,
                       ),
                    ),
                    Text(
                      '${rate.toStringAsFixed(1)}%',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                 SizedBox(height: AppSize.h5,),
                 RateSlider(
                  value: rate,
                  min: 8.0,
                  max: 20.0,
                  divisions: 120,
                  minLabel: '8%',
                  maxLabel: '20%',
                  activeColor: colors.primary,
                  onChanged: (v) => provider.setRate(widget.index, v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
