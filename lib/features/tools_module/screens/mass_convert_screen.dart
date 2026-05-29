import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:finwise/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/anaytics_manager.dart';
import '../../../utils/app_size.dart';
import '../../../utils/navigation_helper.dart';
import '../../../utils/remote_config.dart';
import '../../../widgets/ad_slot.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_summary_background.dart';
import '../../../widgets/app_textfield.dart';

class MassConvertScreen extends StatefulWidget {
  const MassConvertScreen({super.key});

  @override
  State<MassConvertScreen> createState() => _MassConvertScreenState();
}

class _MassConvertScreenState extends State<MassConvertScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _resultKey = GlobalKey();
  bool _hasInput = false;

  String _fromUnit = 'g';
  String _toUnit = 'kg';
  double? _inputValue;
  double? _result;

  InlineAdManager? _inlineAd;

  static const _units = ['g', 'kg', 'lb', 'oz', 't'];
  static const _gradient = [Color(0xFFAD46FF), Color(0xFFF6339A)];

  static const _toKg = {
    'g': 0.001,
    'kg': 1.0,
    'lb': 0.453592,
    'oz': 0.0283495,
    't': 1000.0,
  };

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(screenName: 'mass_convert_screen');
    _loadInline();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasInput) setState(() => _hasInput = has);
    });
  }

  double _convert(double v, String from, String to) {
    if (from == to) return v;
    return v * _toKg[from]! / _toKg[to]!;
  }

  String _fmt(double v) {
    final abs = v.abs();
    if (abs >= 1e6 || (abs != 0 && abs < 1e-3)) {
      return v.toStringAsExponential(4);
    }
    return v.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _convert2() {
    FocusManager.instance.primaryFocus?.unfocus();
    final raw = double.tryParse(_controller.text.trim());
    if (raw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.massValidation)),
      );
      return;
    }
    setState(() {
      _inputValue = raw;
      _result = _convert(raw, _fromUnit, _toUnit);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.0,
        );
      }
    });
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _inputValue = null;
      _result = null;
      _fromUnit = 'g';
      _toUnit = 'kg';
    });
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.massNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    unawaited(_inlineAd?.dispose());
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: context.themeColors.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  AppSize.w16,
                  AppSize.h20,
                  AppSize.w16,
                  AppSize.h10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InputCard(controller: _controller),
                    SizedBox(height: AppSize.h14),
                    _UnitSection(
                      label: context.l10n.converterFromUnit,
                      selected: _fromUnit,
                      units: _units,
                      onSelect: (u) => setState(() {
                        _fromUnit = u;
                        _result = null;
                      }),
                      onClear: () => setState(() {
                        _fromUnit = 'g';
                        _result = null;
                      }),
                    ),
                    SizedBox(height: AppSize.h12),
                    _UnitSection(
                      label: context.l10n.converterToUnit,
                      selected: _toUnit,
                      units: _units,
                      onSelect: (u) => setState(() {
                        _toUnit = u;
                        _result = null;
                      }),
                      onClear: () => setState(() {
                        _toUnit = 'kg';
                        _result = null;
                      }),
                    ),

                    SizedBox(height: AppSize.h14),
                    const _QuickConversionGuideCard(),
                    SizedBox(height: AppSize.h14),
                    const _WhenToUseCard(),
                    if (_result != null && _inputValue != null) ...[
                      SizedBox(height: AppSize.h14),
                      KeyedSubtree(
                        key: _resultKey,
                        child: _ResultCard(
                          inputValue: _inputValue!,
                          fromUnit: _fromUnit,
                          toUnit: _toUnit,
                          result: _result!,
                          inputInKg: _inputValue! * (_toKg[_fromUnit] ?? 1.0),
                          fmt: _fmt,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AdSlot(ad: _inlineAd, safeAreaBottom: false),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x26000000), offset: Offset(0, -1), blurRadius: 4)],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.w20,
                AppSize.h8,
                AppSize.w20,
                AppSize.h0,
              ),
              child:  Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppButton(
                              text: context.l10n.converterButton,
                              suffixIcon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: AppSize.sp17,
                              ),
                              onPressed: _convert2,
                            ),
                             AppButton(
                              text: context.l10n.fdReset,
                              isOutlined: true,
                              onPressed: _reset,
                            ),
                          ],
                        )

            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppSummaryBackground(
      gradientColors: _gradient,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(AppSize.r24),
        bottomRight: Radius.circular(AppSize.r24),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSize.w16,
            AppSize.h10,
            AppSize.w16,
            AppSize.h24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => NavigationHelper().handleBackPress(context),
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: AppSize.sp20,
                ),
              ),
              SizedBox(height: AppSize.h14),
              Text(
                context.l10n.massConverterTitle,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: AppSize.sp24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSize.h4),
              Text(
                context.l10n.massConverterSubtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: AppSize.sp13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Input card ─────────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.massValueLabel,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp14,
            fontWeight: FontWeight.w600,
            color: context.themeTextColors.textColor,
          ),
        ),
        SizedBox(height: AppSize.h10),
        AppTextFormField(
          controller: controller,
          prefixIcon: Assets.temperatureIcons.icMassConvert.svg(
            width: AppSize.w18,
            height: AppSize.w18,
            colorFilter: const ColorFilter.mode(
              Color(0xff64748B),
              BlendMode.srcIn,
            ),
          ),
          hintText: '0',
          contentHeight: AppSize.h12,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
          ],
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSize.h5),
        Text(
          context.l10n.massValueHint,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: AppSize.sp12,
            color: context.themeTextColors.descriptionColor,
          ),
        ),
      ],
    );
  }
}

// ── Unit selection section ─────────────────────────────────────────────────

class _UnitSection extends StatelessWidget {
  const _UnitSection({
    required this.label,
    required this.selected,
    required this.units,
    required this.onSelect,
    required this.onClear,
  });

  final String label;
  final String selected;
  final List<String> units;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: AppSize.sp14,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onClear,
              behavior: HitTestBehavior.opaque,
              child: Text(
                context.l10n.converterClear,
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: AppSize.sp14,
                  color: context.themeColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.h12),
        Row(
          children: units.asMap().entries.map((e) {
            final isLast = e.key == units.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : AppSize.w8),
                child: _UnitChip(
                  label: e.value,
                  isSelected: e.value == selected,
                  onTap: () => onSelect(e.value),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.themeColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: AppSize.h12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [context.themeColors.primary, const Color(0xff153885)],
                )
              : const LinearGradient(
                  colors: [Color(0xffFFffff), Color(0xffE7F1FF)],
                ),
          borderRadius: BorderRadius.circular(AppSize.r24),
          border: Border.all(
            color: isSelected ? primary : const Color(0xFFE2E8F0),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: AppSize.sp14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : context.themeTextColors.textColor,
          ),
        ),
      ),
    );
  }
}

// ── AD banner placeholder ──────────────────────────────────────────────────

class _AdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.h60,
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Text(
        'AD',
        style: context.textTheme.bodyLarge?.copyWith(
          color: context.themeTextColors.descriptionColor,
          fontSize: AppSize.sp14,
        ),
      ),
    );
  }
}

// ── Quick conversion guide card ────────────────────────────────────────────

class _QuickConversionGuideCard extends StatelessWidget {
  const _QuickConversionGuideCard();

  @override
  Widget build(BuildContext context) {
    final guides = [
      (from: '1 kg', to: '2.2 lb', note: context.l10n.massGuideNoteBodyWeight),
      (from: '1 lb', to: '≈ 454 g', note: context.l10n.massGuideNoteCooking),
      (from: '1 oz', to: '≈ 28 g', note: context.l10n.massGuideNoteSmallItems),
      (from: '1 ton', to: '= 1000 kg', note: context.l10n.massGuideNoteHeavy),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.converterQuickConversionGuide,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp14,
              fontWeight: FontWeight.w600,
              color: context.themeTextColors.textColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          ...List.generate(guides.length, (i) {
            final g = guides[i];
            final isLast = i == guides.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSize.h10),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.w10,
                      vertical: AppSize.h6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(AppSize.r8),
                    ),
                    child: Text(
                      '${g.from}  →  ${g.to}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: AppSize.sp12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSize.w10),
                  Expanded(
                    child: Text(
                      g.note,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSize.sp12,
                        color: context.themeTextColors.descriptionColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── When to use card ───────────────────────────────────────────────────────

class _WhenToUseCard extends StatelessWidget {
  const _WhenToUseCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Assets.temperatureIcons.icShippingPackaging,
        title: context.l10n.massWhenShippingTitle,
        desc: context.l10n.massWhenShippingDesc,
        color: const Color(0xFF9810FA),
      ),
      (
        icon: Assets.temperatureIcons.icCookingRecipes,
        title: context.l10n.massWhenCookingTitle,
        desc: context.l10n.massWhenCookingDesc,
        color: const Color(0xFF9810FA),
      ),
      (
        icon: Assets.temperatureIcons.icMassConvert,
        title: context.l10n.massWhenFitnessTitle,
        desc: context.l10n.massWhenFitnessDesc,
        color: const Color(0xFF9810FA),
      ),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.converterWhenToUse,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp14,
              fontWeight: FontWeight.w600,
              color: context.themeTextColors.textColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSize.h12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSize.sp8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSize.r10),
                    ),
                    child: item.icon.svg(
                      width: AppSize.w20,
                      height: AppSize.h20,
                      colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: AppSize.w12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontSize: AppSize.sp13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSize.h3),
                        Text(
                          item.desc,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: AppSize.sp12,
                            color: context.themeTextColors.descriptionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Result card ────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.inputValue,
    required this.fromUnit,
    required this.toUnit,
    required this.result,
    required this.inputInKg,
    required this.fmt,
  });

  final double inputValue;
  final String fromUnit;
  final String toUnit;
  final double result;
  final double inputInKg;
  final String Function(double) fmt;

  String _unitFullName(String unit) {
    switch (unit) {
      case 'g': return 'Gram (g)';
      case 'kg': return 'Kilogram (kg)';
      case 'lb': return 'Pound (lb)';
      case 'oz': return 'Ounce (oz)';
      case 't': return 'Metric Ton (t)';
      default: return unit;
    }
  }

  (String, Color) _weightCategoryOf(BuildContext context, double kg) {
    if (kg < 0.001) return (context.l10n.massCategoryMicro, const Color(0xFF8B5CF6));
    if (kg < 1) return (context.l10n.massCategoryLight, const Color(0xFF06B6D4));
    if (kg < 10) return (context.l10n.tipsSeverityMedium, const Color(0xFF10B981));
    if (kg < 100) return (context.l10n.massCategoryHeavy, const Color(0xFFF59E0B));
    return (context.l10n.massCategoryVeryHeavy, const Color(0xFFEF4444));
  }

  @override
  Widget build(BuildContext context) {
    final (categoryLabel, _) = _weightCategoryOf(context, inputInKg);
    final ratio =
        (inputValue == 0 || result == 0) ? 1.0 : (result / inputValue).abs();

    return Column(
      children: [
        AppSummaryBackground(
          gradientColors: const [Color(0xFFAD46FF), Color(0xFFF6339A)],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.r26),
            topRight: Radius.circular(AppSize.r26),
          ),
          useImage: true,
          imagePath: 'assets/images/splash_screen.png',
          imageOpacity: 0.6,
          backgroundColor: const Color(0xFFF6339A),
          child: Padding(
            padding: EdgeInsets.all(AppSize.w20),
            child: Column(
              children: [
                // Category badge
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.h5,
                    horizontal: AppSize.w12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSize.r20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.temperatureIcons.icMassConvert.svg(
                        height: AppSize.h14,
                        width: AppSize.w14,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: AppSize.w6),
                      Text(
                        categoryLabel,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontSize: AppSize.sp14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Large result number
                Text(
                  fmt(result),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: AppSize.sp60,
                  ),
                ),
                Text(
                  _unitFullName(toUnit),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: AppSize.sp18,
                  ),
                ),
                SizedBox(height: AppSize.h16),
                Divider(color: Colors.white.withValues(alpha: 0.3)),
                // From → To row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          context.l10n.converterFromLabel,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: AppSize.sp12,
                          ),
                        ),
                        Text(
                          '${fmt(inputValue)} $fromUnit',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: AppSize.sp18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: AppSize.w20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSize.w8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: AppSize.sp16,
                      ),
                    ),
                    SizedBox(width: AppSize.w20),
                    Column(
                      children: [
                        Text(
                          context.l10n.converterToLabel,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: AppSize.sp12,
                          ),
                        ),
                        Text(
                          '${fmt(result)} $toUnit',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: AppSize.sp18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(AppSize.sp22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppSize.r26),
              bottomRight: Radius.circular(AppSize.r26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: AppSize.r6,
                offset: Offset(0, AppSize.h5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniValueCard(
                      label: context.l10n.converterSourceLabel,
                      value: fmt(inputValue),
                      unit: fromUnit,
                    ),
                  ),
                  SizedBox(width: AppSize.w12),
                  Expanded(
                    child: _MiniValueCard(
                      label: context.l10n.converterConvertedLabel,
                      value: fmt(result),
                      unit: toUnit,
                      isHighlighted: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.h14),
              _RelativeScaleCard(ratio: ratio),
              SizedBox(height: AppSize.h14),
              const _CommonReferencesCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniValueCard extends StatelessWidget {
  const _MiniValueCard({
    required this.label,
    required this.value,
    required this.unit,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w12,
        vertical: AppSize.h18,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xff059669).withValues(alpha: 0.1)
            : const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: isHighlighted
            ? Border.all(
                color: const Color(0xff059669).withValues(alpha: 0.2),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.themeTextColors.descriptionColor,
              fontSize: AppSize.sp14,
            ),
          ),
          SizedBox(height: AppSize.h4),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(fontSize: AppSize.sp18),
          ),
          Text(
            unit,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.themeTextColors.descriptionColor,
              fontSize: AppSize.sp14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Relative scale card ────────────────────────────────────────────────────

class _RelativeScaleCard extends StatelessWidget {
  const _RelativeScaleCard({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final cappedProgress = (ratio > 10 ? 10.0 : ratio) / 10.0;
    final label = ratio > 1
        ? context.l10n.converterRatioLarger(ratio.toStringAsFixed(2))
        : ratio < 1
            ? context.l10n.converterRatioSmaller((1 / ratio).toStringAsFixed(2))
            : context.l10n.converterRatioEqual;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w14,
        vertical: AppSize.h12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(AppSize.r14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.converterRelativeScale,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSize.h8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.r4),
                  child: LinearProgressIndicator(
                    value: cappedProgress,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFEF4444),
                    ),
                    minHeight: AppSize.h8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSize.w12),
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp12,
              color: const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Common references card ─────────────────────────────────────────────────

class _CommonReferencesCard extends StatelessWidget {
  const _CommonReferencesCard();

  @override
  Widget build(BuildContext context) {
    final refs = [
      context.l10n.massRef1,
      context.l10n.massRef2,
      context.l10n.massRef3,
      context.l10n.massRef4,
    ];
    return _Card(
      color: context.themeColors.primary.withValues(alpha: 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.converterCommonReferences,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp14,
            ),
          ),
          SizedBox(height: AppSize.h10),
          ...refs.map(
            (ref) => Padding(
              padding: EdgeInsets.only(bottom: AppSize.h6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: AppSize.h5),
                    child: Container(
                      width: AppSize.w4,
                      height: AppSize.h4,
                      decoration: BoxDecoration(
                        color: context.themeTextColors.descriptionColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSize.w8),
                  Expanded(
                    child: Text(
                      ref,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSize.sp12,
                        color: context.themeTextColors.descriptionColor,
                      ),
                    ),
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

// ── Shared card container ──────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: color ?? context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r24),
        border: Border.all(
          color: context.themeColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: AppSize.r10,
            offset: Offset(0, AppSize.h3),
          ),
        ],
      ),
      child: child,
    );
  }
}
