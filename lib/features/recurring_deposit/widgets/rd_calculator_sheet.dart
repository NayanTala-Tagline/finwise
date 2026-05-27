import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';
import '../../../widgets/common_appbar.dart';
import '../provider/recurring_deposit_provider.dart';
import 'rd_result_sheet.dart';

class RdCalculatorSheet extends StatefulWidget {
  const RdCalculatorSheet({super.key});

  @override
  State<RdCalculatorSheet> createState() => _RdCalculatorSheetState();
}

class _RdCalculatorSheetState extends State<RdCalculatorSheet> {
  static const List<String> _tenureUnits = ['Month', 'Year'];

  void _pickDate(BuildContext context) async {
    final provider = context.read<RecurringDepositProvider>();
    final primary = context.themeColors.primary;
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: primary,
            onPrimary: Colors.white,
            surface: ctx.themeColors.whiteColor,
            onSurface: ctx.themeTextColors.textColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) provider.setStartDate(picked);
  }

  void _calculate(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    final provider = context.read<RecurringDepositProvider>();
    if (!provider.isInputValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid values greater than zero.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    provider.calculate();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const RdResultSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringDepositProvider>();
    final dateLabel = DateFormat('dd/MM/yyyy').format(provider.startDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        titleText: 'RD Calculator',
        onBackPress: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSize.h24),

                  // Monthly Deposit
                  AppTextFormField(
                    title: 'Monthly Deposit',
                    controller: provider.depositController,
                    hintText: 'Enter monthly deposit amount',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: (_) {},
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: AppSize.w16),
                      child: Text('₹', style: context.textTheme.bodyLarge?.copyWith(fontSize: AppSize.sp16)),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: AppSize.w30, minHeight: 0),
                  ),
                  SizedBox(height: AppSize.h20),

                  // Interest Rate
                  AppTextFormField(
                    title: 'Interest Rate',
                    controller: provider.rateController,
                    hintText: 'Enter interest rate',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: (_) {},
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: AppSize.w16),
                      child: Text('%', style: context.textTheme.bodyLarge?.copyWith(fontSize: AppSize.sp16)),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: AppSize.w30, minHeight: 0),
                  ),
                  SizedBox(height: AppSize.h20),

                  // Tenure
                  _TenureRow(tenureUnits: _tenureUnits, provider: provider),
                  SizedBox(height: AppSize.h20),

                  // Start Date
                  AppTextFormField(
                    title: 'Start Date',
                    controller: TextEditingController(text: dateLabel),
                    hintText: dateLabel,
                    readOnly: true,
                    onTap: () => _pickDate(context),
                    suffixIcon: GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Padding(
                        padding: EdgeInsets.only(right: AppSize.w16),
                        child: Icon(Icons.calendar_today_outlined, size: AppSize.sp20, color: context.themeColors.primary),
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: AppSize.w30, minHeight: 0),
                  ),
                  SizedBox(height: AppSize.h32),
                ],
              ),
            ),
          ),

          // ── Bottom Button ────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Color(0x26000000), offset: Offset(0, -1), blurRadius: 4),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSize.w16, AppSize.h8, AppSize.w16, AppSize.h0),
                child: AppButton(
                  text: 'Calculate',
                  borderRadius: AppSize.r50,
                  suffixIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  onPressed: () => _calculate(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenureRow extends StatelessWidget {
  const _TenureRow({required this.tenureUnits, required this.provider});

  final List<String> tenureUnits;
  final RecurringDepositProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSize.w6),
          child: Text(
            'Tenure',
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp17,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(height: AppSize.h12),
        Row(
          children: [
            Expanded(
              child: AppTextFormField(
                controller: provider.tenureController,
                hintText: 'Duration',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                onChanged: (_) {},
              ),
            ),
            SizedBox(
              width: AppSize.w130,
              child: AppTextFormField(
                dropdownItems: tenureUnits,
                dropdownValue: provider.tenureUnitLabel,
                onDropdownChanged: (v) {
                  if (v != null) provider.setTenureUnit(v);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
