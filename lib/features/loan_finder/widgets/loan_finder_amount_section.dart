import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';

/// Amount entry block: tap-anywhere "Enter Amount" card, custom track-and-
/// triangle slider and a wrap of preset chips. Owns one numeric value.
class LoanFinderAmountSection extends StatefulWidget {
  const LoanFinderAmountSection({
    super.key,
    required this.value,
    required this.onChanged,
    required this.presets,
    this.min = 1000,
    this.max = 90000,
    this.showSlider = true,
    this.label,
    this.amountColor,
    this.amountLabel,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final List<int> presets;
  final double min;
  final double max;
  final bool showSlider;
  final String? label;
  final Color? amountColor;
  final String? amountLabel;

  @override
  State<LoanFinderAmountSection> createState() =>
      _LoanFinderAmountSectionState();
}

class _LoanFinderAmountSectionState extends State<LoanFinderAmountSection> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toInt().toString());
    _focusNode = FocusNode()
      ..addListener(() {
        if (!_focusNode.hasFocus) _commitTextField();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double get _safeValue =>
      widget.value.clamp(widget.min, widget.max).toDouble();

  void _commitTextField() {
    final parsed = double.tryParse(_controller.text) ?? widget.value;
    final clamped = parsed.clamp(widget.min, widget.max).toDouble();
    final text = clamped.toInt().toString();
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    widget.onChanged(clamped);
  }

  void _setExternalValue(double v) {
    final clamped = v.clamp(widget.min, widget.max).toDouble();
    final text = clamped.toInt().toString();
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SizedBox(height: AppSize.h20),
        // ── Large Amount Display ───────────────────────────────────────────
        Text(
          '₹${_formatAmount(_safeValue.toInt())}',
          style: context.textTheme.titleLarge?.copyWith(
            color: widget.amountColor ?? colors.primary,
            fontSize: AppSize.sp48,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSize.h8),
        Text(
          widget.amountLabel ?? 'Loan amount',
          style: context.textTheme.bodyMedium?.copyWith(
            color: textColors.descriptionColor,
            fontSize: AppSize.sp14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSize.h32),
        // ── Slider Card ────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.all(AppSize.w20),
          decoration: BoxDecoration(
            color: colors.whiteColor,
            borderRadius: BorderRadius.circular(AppSize.r20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff000000).withValues(alpha: 0.1),
                blurRadius: AppSize.r6,
                offset: Offset(0, AppSize.h8),
                spreadRadius: -AppSize.sp2
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Loan amount',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: textColors.textColor,
                      fontSize: AppSize.sp15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${_formatAmount(_safeValue.toInt())}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: widget.amountColor ?? colors.primary,
                      fontSize: AppSize.sp15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.h16),
              _AmountSlider(
                value: _safeValue,
                min: widget.min,
                max: widget.max,
                onChanged: _setExternalValue,
                amountColor: widget.amountColor,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.h24),
        // ── Preset Chips ───────────────────────────────────────────────────
        Wrap(
          spacing: AppSize.w12,
          runSpacing: AppSize.h12,
          alignment: WrapAlignment.center,
          children: widget.presets
              .map((preset) => _PresetChip(
                    value: preset,
                    selected: preset.toDouble() == widget.value,
                    onTap: () => _setExternalValue(preset.toDouble()),
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 10000000) {
      // Crore
      final crore = amount / 10000000;
      return crore == crore.toInt()
          ? '${crore.toInt()},00,00,000'
          : '${crore.toStringAsFixed(2).replaceAll('.', ',')}0,00,000';
    } else if (amount >= 100000) {
      // Lakh
      final lakh = amount / 100000;
      return lakh == lakh.toInt()
          ? '${lakh.toInt()},00,000'
          : '${(amount / 100000).toStringAsFixed(0)},00,000';
    } else if (amount >= 1000) {
      // Thousand
      final thousand = amount / 1000;
      return thousand == thousand.toInt()
          ? '${thousand.toInt()},000'
          : amount.toString();
    }
    return amount.toString();
  }
}

// ── Custom slider ──────────────────────────────────────────────────────────

class _AmountSlider extends StatelessWidget {
  const _AmountSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.amountColor,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    final t = max == min
        ? 0.0
        : ((value - min) / (max - min)).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final pos = t * w;

      void emit(double localX) {
        final newT = (localX / w).clamp(0.0, 1.0);
        onChanged(min + newT * (max - min));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => emit(d.localPosition.dx),
            onPanUpdate: (d) => emit(d.localPosition.dx),
            child: SizedBox(
              height: AppSize.h20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Inactive track
                  Positioned(
                    left: 0,
                    right: 0,
                    top: AppSize.h9,
                    child: Container(
                      height: AppSize.h6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(AppSize.r2),
                      ),
                    ),
                  ),
                  // Active fill
                  Positioned(
                    left: 0,
                    top: AppSize.h9,
                    child: Container(
                      width: pos,
                      height: AppSize.h6,
                      decoration: BoxDecoration(
                        color: amountColor ?? colors.primary,
                        borderRadius: BorderRadius.circular(AppSize.r2),
                      ),
                    ),
                  ),
                  // Thumb
                  Positioned(
                    left: pos - AppSize.w10,
                    top: 0,
                    child: Container(
                      width: AppSize.w20,
                      height: AppSize.h20,
                      decoration: BoxDecoration(
                        color: amountColor ?? colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSize.h8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.w2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatSliderLabel(min.toInt()),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textColors.descriptionColor,
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _formatSliderLabel(max.toInt()),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textColors.descriptionColor,
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  String _formatSliderLabel(int amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toInt()}Cr.';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toInt()}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toInt()}K';
    }
    return '₹$amount';
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ── Preset chip ────────────────────────────────────────────────────────────

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w20,
          vertical: AppSize.h12,
        ),
         decoration: BoxDecoration(
             gradient: selected ? LinearGradient(colors: [context.themeColors.primary,Color(0xff153885),]) : LinearGradient(colors: [Colors.white,Color(0xffE7F1FF),]),
             borderRadius: BorderRadius.circular(AppSize.r24),
          border: Border.all(
            color: selected ? colors.primary : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Text(
          _formatPreset(value),
          style: context.textTheme.titleSmall?.copyWith(
            color: selected ? Colors.white : textColors.textColor,
            fontWeight: FontWeight.w600,
            fontSize: AppSize.sp15,
          ),
        ),
      ),
    );
  }

  String _formatPreset(int amount) {
    if (amount >= 10000000) {
      final crore = amount / 10000000;
      return '₹${crore.toInt()}Cr.';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      return '₹${lakh.toInt()}L';
    } else if (amount >= 1000) {
      final thousand = amount / 1000;
      return '₹${thousand.toInt()}K';
    }
    return '₹$amount';
  }
}
