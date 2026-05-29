import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../extension/ext_context.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/anaytics_manager.dart';
import '../../../utils/app_size.dart';
import '../../../utils/navigation_helper.dart';
import '../../../utils/remote_config.dart';
import '../../../widgets/ad_slot.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';
import '../../../widgets/common_appbar.dart';
import '../provider/tools_provider.dart';
import 'result_row.dart';
import 'section_title.dart';

/// Generic converter scaffold shared by Temperature / Mass / Speed / Length.
///
/// Set [showConvertTo] to false for the Temperature converter — its result
/// list shows every other unit instead of a fixed target.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({
    super.key,
    required this.title,
    required this.kind,
    required this.units,
    required this.fromLabel,
    this.toLabel,
    this.showConvertTo = true,
  });

  final String title;
  final ConverterKind kind;
  final List<String> units;
  final String fromLabel;
  final String? toLabel;
  final bool showConvertTo;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late final TextEditingController _inputController;
  final GlobalKey _resultKey = GlobalKey();

  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ToolsProvider>();
    _inputController = TextEditingController(text: provider.inputOf(widget.kind));
    _loadInline();
    AnalyticsManager.instance.logScreenView(
      screenName: 'converter_${widget.kind.name}_screen',
    );
  }

  void _loadInline() {
    final rc = RemoteConfigService.instance;
    final data = switch (widget.kind) {
      ConverterKind.temperature => rc.temperatureNative,
      ConverterKind.mass => rc.massNative,
      ConverterKind.speed => rc.speedNative,
      ConverterKind.length => rc.lengthNative,
    };
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    _inputController.dispose();
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  void _scrollToResult() {
    final ctx = _resultKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.1,
    );
  }

  String _format(double value) {
    if (value == 0) return '0';
    final abs = value.abs();
    if (abs >= 1e6 || (abs < 1e-3 && abs != 0)) {
      return value.toStringAsExponential(4);
    }
    final fixed = value.toStringAsFixed(4);
    // strip trailing zeros / dot
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToolsProvider>();
    final fromUnit = provider.fromUnitOf(widget.kind);
    final toUnit = provider.toUnitOf(widget.kind);
    final calculated = provider.isCalculatedOf(widget.kind);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
      backgroundColor: Color(0xffFFFAF9),
      appBar: CommonAppBar(
        titleText: widget.title,
        titleTextStyle: context.textTheme.bodyMedium?.copyWith(fontSize: AppSize.sp20,fontWeight: FontWeight.w500),
        leading: GestureDetector(
          onTap: (){
            NavigationHelper().handleBackPress(context);
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSize.h6),
            child: Center(
              child: Assets.personalLoanIcons.icBack.svg(
                width: AppSize.w24,
                height: AppSize.h24,
                colorFilter: ColorFilter.mode(
                  context.themeTextColors.textColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        showLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w20,vertical: AppSize.h25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle(title: widget.fromLabel),
              SizedBox(height: AppSize.h12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppSize.w120,
                      child: AppTextFormField(
                        controller: _inputController,
                        contentHeight: AppSize.h10,
                        hintText: '0',
                        style: context.textTheme.bodyMedium?.copyWith(fontSize: AppSize.sp16,fontWeight: FontWeight.w500),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        onChanged: (v) =>
                            provider.setInput(widget.kind, v ?? ''),
                      ),
                    ),
                    Expanded(
                      child: _UnitDropdown(
                        value: fromUnit,
                        items: widget.units,
                        onChanged: (v) => provider.setFromUnit(widget.kind, v),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.h20),
              if (widget.showConvertTo) ...[
                SectionTitle(title: widget.toLabel ?? context.l10n.converterConvertTo),
                SizedBox(height: AppSize.h12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w6),
                  child: _UnitDropdown(
                    value: toUnit,
                    items: widget.units,
                    onChanged: (v) => provider.setToUnit(widget.kind, v),
                  ),
                ),
                SizedBox(height: AppSize.h20),
              ],
              if (calculated) ...[
                SectionTitle(key: _resultKey, title: context.l10n.fdResult),
                SizedBox(height: AppSize.h12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w6),
                  child: _ResultCard(
                    rows: _buildResultRows(
                      provider: provider,
                      fromUnit: fromUnit,
                      toUnit: toUnit,
                      calculated: calculated,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdSlot(ad: _inlineAd, safeAreaBottom: false),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.w20,
                AppSize.h8,
                AppSize.w20,
                AppSize.h10,
              ),
              child: Column(
                spacing: AppSize.h8,
                children: [
                  AppButton(
                    text: context.l10n.converterButton,
                    textStyle: context.textTheme.bodyMedium?.copyWith(
                        fontSize: AppSize.sp14,
                        fontWeight: FontWeight.w500
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final raw = double.tryParse(_inputController.text.trim());
                      if (raw == null || raw <= 0) {
                        AnalyticsManager.instance.logEvent(
                          name: 'converter_validation_failed',
                          parameters: {'kind': widget.kind.name},
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.converterValidation)),
                        );
                        return;
                      }
                      AnalyticsManager.instance.logEvent(
                        name: 'converter_convert',
                        parameters: {
                          'kind': widget.kind.name,
                          'from_unit': fromUnit,
                          'to_unit': toUnit,
                        },
                      );
                      provider.convert(widget.kind);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToResult();
                      });
                    },
                  ),
                  AppButton(
                    text: context.l10n.converterRefresh,
                    isOutlined: true,
                    textStyle: context.textTheme.bodyMedium?.copyWith(
                        fontSize: AppSize.sp16,
                        color: context.themeTextColors.descriptionColor,
                        fontWeight: FontWeight.w400
                    ),
                    onPressed: () {
                      AnalyticsManager.instance.logEvent(
                        name: 'converter_refresh',
                        parameters: {'kind': widget.kind.name},
                      );
                      _inputController.clear();
                      provider.refresh(widget.kind);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  List<_ResultRowData> _buildResultRows({
    required ToolsProvider provider,
    required String fromUnit,
    required String toUnit,
    required bool calculated,
  }) {
    if (widget.kind == ConverterKind.temperature) {
      // Show every unit other than the source.
      final targets = widget.units.where((u) => u != fromUnit).toList();
      return [
        for (final unit in targets)
          _ResultRowData(
            label: unit,
            value: calculated
                ? _format(provider.convertValue(
                    kind: widget.kind,
                    fromUnit: fromUnit,
                    toUnit: unit,
                  ))
                : '0',
          ),
      ];
    }

    return [
      _ResultRowData(
        label: fromUnit,
        value: calculated
            ? _format(provider.convertValue(
                kind: widget.kind,
                fromUnit: fromUnit,
                toUnit: fromUnit,
              ))
            : '0',
      ),
      _ResultRowData(
        label: toUnit,
        value: calculated
            ? _format(provider.convertValue(
                kind: widget.kind,
                fromUnit: fromUnit,
                toUnit: toUnit,
              ))
            : '0',
      ),
    ];
  }
}

class _ResultRowData {
  const _ResultRowData({required this.label, required this.value});

  final String label;
  final String value;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.rows});

  final List<_ResultRowData> rows;

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
              label: rows[i].label,
              value: rows[i].value,
              showDivider: i != rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      dropdownItems: items,
      dropdownValue: value,
      contentHeight: AppSize.h10,
      style: context.textTheme.bodyMedium?.copyWith(
        fontSize: AppSize.sp12,
        fontWeight: FontWeight.w500
      ),
      onDropdownChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
