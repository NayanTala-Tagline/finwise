import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ad_manager/ad_manager.dart';

import '../../../extension/ext_context.dart';
import '../../currency_screen/provider/currency_provider.dart';
import '../../../utils/app_size.dart';
import '../../../utils/remote_config.dart';
import '../../../widgets/ad_slot.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';
import '../../../widgets/common_appbar.dart';
import '../provider/fixed_deposit_provider.dart';
import 'fd_result_sheet.dart';

class FdCalculatorSheet extends StatefulWidget {
  const FdCalculatorSheet({super.key});

  @override
  State<FdCalculatorSheet> createState() => _FdCalculatorSheetState();
}

class _FdCalculatorSheetState extends State<FdCalculatorSheet> {
  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.fixedDepositCalculatorNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  void _pickDate(BuildContext context) async {
    final provider = context.read<FixedDepositProvider>();
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
    final provider = context.read<FixedDepositProvider>();
    if (!provider.isInputValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.fdCalculatorValidation),
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
          child: const FdResultSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<FixedDepositProvider>();
    final sym = context.watch<CurrencyProvider>().symbol;
    final dateLabel = DateFormat('dd/MM/yyyy').format(provider.startDate);
    final tenureUnits = [l10n.compareCardMonth, l10n.compareCardYear];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        titleText: l10n.homeFdCalculator,
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
                  AppTextFormField(
                    title: l10n.fdCalculatorInvestmentAmount,
                    controller: provider.amountController,
                    hintText: l10n.fdCalculatorInvestmentAmountHint,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: (_) {},
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: AppSize.w16),
                      child: Text(sym, style: context.textTheme.bodyLarge?.copyWith(fontSize: AppSize.sp16)),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: AppSize.w30, minHeight: 0),
                  ),
                  SizedBox(height: AppSize.h20),
                  AppTextFormField(
                    title: l10n.fdCalculatorInterestRate,
                    controller: provider.rateController,
                    hintText: l10n.fdCalculatorInterestRateHint,
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
                  _TenureRow(tenureUnits: tenureUnits, provider: provider),
                  SizedBox(height: AppSize.h20),
                  AppTextFormField(
                    title: l10n.fdCalculatorStartDate,
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
          AdSlot(ad: _inlineAd, safeAreaBottom: false),
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
                  text: l10n.fdCalculateButton,
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
  final FixedDepositProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSize.w6),
          child: Text(
            context.l10n.fdCalculatorTenure,
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
                hintText: context.l10n.fdCalculatorDurationHint,
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
