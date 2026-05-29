import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/features/currency_screen/provider/currency_provider.dart';
import 'package:finwise/utils/remote_config.dart';
import 'package:finwise/widgets/ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/common_appbar.dart';
import '../../widgets/rate_slider.dart';
import 'loan_calculator_result_screen.dart';
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
  void _calculate(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    final provider = context.read<LoanCalculatorProvider>();
    if (!provider.isInputValid) {
      context.l10n.loanCalculatorValidation.showErrorAlert();
      return;
    }
    provider.calculate();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const LoanCalculatorResultScreen(),
        ),
      ),
    );
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

  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'loan_calculator_screen');
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
    final currencySymbol = context.watch<CurrencyProvider>().symbol;
    final textColors = context.themeTextColors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: CommonAppBar(
          titleText: context.l10n.loanCalculatorTitle,
          titleTextStyle: context.textTheme.bodyMedium?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w700,
          ),
          leading: GestureDetector(
            onTap: () => NavigationHelper().handleBackPress(context),
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
        body: _FormView(
          provider: provider,
          currencySymbol: currencySymbol,
          onPickDate: () => _pickDate(context),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdSlot(ad: _inlineAd, safeAreaBottom: false, safeAreaTop: false),
            _FormBottomBar(onCalculate: () => _calculate(context)),
          ],
        ),
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
          _FieldLabel(label: context.l10n.loanCalculatorLoanAmount),
          SizedBox(height: AppSize.h8),
          AppTextFormField(
            controller: provider.loanAmountController,
            hintText: context.l10n.loanCalculatorLoanAmountHint,
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
          _FieldLabel(label: context.l10n.loanCalculatorLoanTerm),
          SizedBox(height: AppSize.h8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AppTextFormField(
                  controller: provider.loanTermController,
                  hintText: context.l10n.loanCalculatorLoanTermHint,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                  onChanged: (_) {},
                ),
              ),
              SizedBox(width: AppSize.w10),
              Expanded(
                flex: 2,
                child: AppTextFormField(
                  hintText: context.l10n.loanCalculatorMonths,
                  dropdownItems: [context.l10n.loanCalculatorMonths, context.l10n.loanCalculatorYears],
                  dropdownValue: provider.isMonths ? context.l10n.loanCalculatorMonths : context.l10n.loanCalculatorYears,
                  onDropdownChanged: (v) => provider.setIsMonths(v == context.l10n.loanCalculatorMonths),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h20),
          _FieldLabel(label: context.l10n.loanCalculatorStartDate),
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
          padding: EdgeInsets.fromLTRB(AppSize.w20, AppSize.h12, AppSize.w20, AppSize.h0),
          child: AppButton(
            text: context.l10n.loanCalculatorButton,
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
              Text(
                context.l10n.fdCalculatorInterestRate,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSize.sp16,
                ),
              ),
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSize.sp16,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h16),
          RateSlider(value: rate, min: _min, max: _max, onChanged: onChanged, minLabel: '8%', maxLabel: '20%'),
        ],
      ),
    );
  }
}
