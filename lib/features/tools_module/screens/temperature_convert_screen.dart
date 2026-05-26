import 'package:finwise/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import '../../../utils/navigation_helper.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_summary_background.dart';
import '../../../widgets/app_textfield.dart';

class TemperatureConvertScreen extends StatefulWidget {
  const TemperatureConvertScreen({super.key});

  @override
  State<TemperatureConvertScreen> createState() =>
      _TemperatureConvertScreenState();
}

class _TemperatureConvertScreenState extends State<TemperatureConvertScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _resultKey = GlobalKey();

  String _fromUnit = '°C';
  String _toUnit = '°F';
  double? _inputValue;
  double? _result;

  static const _units = ['°C', '°F', 'K'];
  static const _gradient = [Color(0xFFE64A19), Color(0xFFFF7043)];

  // ── Conversion ─────────────────────────────────────────────────────────────

  double _toCelsius(double v, String from) {
    switch (from) {
      case '°F':
        return (v - 32) * 5 / 9;
      case 'K':
        return v - 273.15;
      default:
        return v;
    }
  }

  double _fromCelsius(double c, String to) {
    switch (to) {
      case '°F':
        return c * 9 / 5 + 32;
      case 'K':
        return c + 273.15;
      default:
        return c;
    }
  }

  double _convert(double v, String from, String to) =>
      from == to ? v : _fromCelsius(_toCelsius(v, from), to);

  String _fmt(double v) {
    final abs = v.abs();
    if (abs >= 1e6 || (abs != 0 && abs < 1e-3)) {
      return v.toStringAsExponential(4);
    }
    return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  (String label, Color color) _comfort(double celsius) {
    if (celsius < 0) return ('Freezing', const Color(0xFF3B82F6));
    if (celsius < 10) return ('Cold', const Color(0xFF60A5FA));
    if (celsius < 18) return ('Cool', const Color(0xFF06B6D4));
    if (celsius < 24) return ('Comfortable', const Color(0xFF10B981));
    if (celsius < 32) return ('Warm', const Color(0xFFF59E0B));
    return ('Hot', const Color(0xFFEF4444));
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _convert2() {
    FocusManager.instance.primaryFocus?.unfocus();
    final raw = double.tryParse(_controller.text.trim());
    if (raw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid temperature value')),
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
      _fromUnit = '°C';
      _toUnit = '°F';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
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
                      label: 'From Unit',
                      selected: _fromUnit,
                      units: _units,
                      onSelect: (u) => setState(() {
                        _fromUnit = u;
                        _result = null;
                      }),
                      onClear: () => setState(() {
                        _fromUnit = '°C';
                        _result = null;
                      }),
                    ),
                    SizedBox(height: AppSize.h12),
                    _UnitSection(
                      label: 'To Unit',
                      selected: _toUnit,
                      units: _units,
                      onSelect: (u) => setState(() {
                        _toUnit = u;
                        _result = null;
                      }),
                      onClear: () => setState(() {
                        _toUnit = '°F';
                        _result = null;
                      }),
                    ),
                    SizedBox(height: AppSize.h14),
                    _ConversionFormulasCard(),
                    if (_result != null && _inputValue != null) ...[
                      SizedBox(height: AppSize.h14),
                      KeyedSubtree(
                        key: _resultKey,
                        child: _ResultCard(
                          inputValue: _inputValue!,
                          fromUnit: _fromUnit,
                          toUnit: _toUnit,
                          result: _result!,
                          celsius: _toCelsius(_inputValue!, _fromUnit),
                          fmt: _fmt,
                          comfort: _comfort,
                        ),
                      ),
                    ],
                   ],
                ),
              ),
            ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: 'Convert',
                    suffixIcon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: AppSize.sp17,
                    ),
                    onPressed: _convert2,
                  ),
                   AppButton(text: 'Reset', isOutlined: true, onPressed: _reset),
                ],
              ),
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
                'Temperature Converter',
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: AppSize.sp24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSize.h4),
              Text(
                'Instant temperature unit conversion',
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
          'Temperature Value',
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp14,
            fontWeight: FontWeight.w600,
            color: context.themeTextColors.textColor,
          ),
        ),
        SizedBox(height: AppSize.h10),
        AppTextFormField(
          controller: controller,
          prefixIcon: Assets.temperatureIcons.icTemperatureConvert.svg(
            width: AppSize.w18,
            height: AppSize.w18,
            colorFilter: ColorFilter.mode(Color(0xff64748B), BlendMode.srcIn),
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
          'Enter any temperature value to convert',
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
                'Clear',
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
                  colors: [context.themeColors.primary, Color(0xff153885)],
                )
              : LinearGradient(colors: [Color(0xffFFffff), Color(0xffE7F1FF)]),
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
            color: isSelected
                ? Colors.white
                : context.themeTextColors.textColor,
          ),
        ),
      ),
    );
  }
}

// ── Conversion formulas card ───────────────────────────────────────────────

class _ConversionFormulasCard extends StatelessWidget {
  static const _formulas = [
    (
      letter: 'C',
      color: Color(0xFF3B82F6),
      text: '°F = (°C × 9/5) + 32   |   K = °C + 273.15',
    ),
    (
      letter: 'F',
      color: Color(0xFFEF4444),
      text: '°C = (°F − 32) × 5/9   |   K = (°F−32)×5/9 + 273.15',
    ),
    (
      letter: 'K',
      color: Color(0xFF8B5CF6),
      text: '°C = K − 273.15   |   °F = (K − 273.15) × 9/5 + 32',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversion Formulas',
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp14,
              fontWeight: FontWeight.w600,
              color: context.themeTextColors.textColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          ...List.generate(_formulas.length, (i) {
            final f = _formulas[i];
            final isLast = i == _formulas.length - 1;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: AppSize.w26,
                      height: AppSize.h26,
                      decoration: BoxDecoration(
                        color: Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(AppSize.r6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        f.letter,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: AppSize.sp12,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSize.w10),
                    Expanded(
                      child: Text(
                        f.text,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: AppSize.sp12,
                          color: context.themeTextColors.descriptionColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) ...[SizedBox(height: AppSize.h10)],
              ],
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
    required this.celsius,
    required this.fmt,
    required this.comfort,
  });

  final double inputValue;
  final String fromUnit;
  final String toUnit;
  final double result;
  final double celsius;
  final String Function(double) fmt;
  final (String, Color) Function(double) comfort;

  @override
  Widget build(BuildContext context) {
    final (comfortLabel, comfortColor) = comfort(celsius);

    return Column(
      children: [
        AppSummaryBackground(
          gradientColors: const [Color(0xFFFB2C36), Color(0xFFFF6900)],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.r26),
            topRight: Radius.circular(AppSize.r26),
          ),
          useImage: true,
          imagePath: 'assets/images/splash_screen.png',
          imageOpacity: 0.6,
          backgroundColor: Color(0xFFFF6900),
          child: Padding(
            padding: EdgeInsets.all(AppSize.w20),
            child: Column(
              children: [
                // Comfort badge
                Container(
                  padding: EdgeInsets.symmetric(vertical: AppSize.h5),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSize.r20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.temperatureIcons.icTemperatureConvert.svg(
                        height: AppSize.h14,
                        width: AppSize.w14,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        comfortLabel,
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
                  _unitName(toUnit),
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
                          'From',
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
                          'To',
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
                color: const Color(0xFF000000).withValues(alpha: 0.2),
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
                      label: 'Source',
                      value: fmt(inputValue),
                      unit: fromUnit,
                    ),
                  ),
                  SizedBox(width: AppSize.w12),
                  Expanded(
                    child: _MiniValueCard(
                      label: 'Converted',
                      value: fmt(result),
                      unit: toUnit,
                      isHighlighted: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.h14),
              _QuickReferenceCard(),
            ],
          ),
        ),
      ],
    );
  }

  String _unitName(String unit) {
    switch (unit) {
      case '°C':
        return 'Celsius (°C)';
      case '°F':
        return 'Fahrenheit (°F)';
      case 'K':
        return 'Kelvin (K)';
      default:
        return unit;
    }
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
        color: label == "Source"
            ? Color(0xffF1F5F9)
            : Color(0xff059669).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: label == "Source"
            ? null
            : Border.all(color: Color(0xff059669).withValues(alpha: 0.2)),
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
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp18,
            ),
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

// ── Quick reference card ───────────────────────────────────────────────────

class _QuickReferenceCard extends StatelessWidget {
  static const _refs = [
    'Water freezes at 0°C / 32°F / 273.15K',
    'Water boils at 100°C / 212°F / 373.15K',
    'Room temperature = 20-25°C / 68-77°F',
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      color: context.themeColors.primary.withValues(alpha: 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Reference',
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp14,
            ),
          ),
          SizedBox(height: AppSize.h10),
          ..._refs.map(
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
