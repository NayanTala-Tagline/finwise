import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

/// Common Text filed
class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    this.title,
    this.titleStyle,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.hintText,
    this.shadow,
    this.labelText,
    this.labelColor,
    this.inputFormatters,
    this.maxTextLength = 255,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.subTitle,
    this.isStartTime = true,
    super.key,
    this.textAction,
    this.suffix,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.cursorColor,
    this.inputBorder,
    this.minLine = 1,
    this.maxLine = 1,
    this.fillColor,
    this.isFilled = true,
    this.titleColor,
    this.focusNode,
    this.fontSize,
    this.onSaved,
    this.contentHeight,
    this.borderRadius,
    this.style,
    this.contentWidth,
    this.hintStyle,
    this.borderSide,
    this.textAlignVertical,
    this.prefix,
    this.isDense,
    this.prefixIconConstraints,
    this.autofocus,
    this.suffixIconConstraints,
    this.floatingLabelColor,
    this.autofillHints,
    this.textAlign = TextAlign.start,
    this.textColor,
    this.autovalidateMode,
    this.dropdownItems,
    this.dropdownValue,
    this.onDropdownChanged,
    this.showCompareTextField = false,
    this.horizontalLabelWidth,
  });
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? title;
  final TextStyle? titleStyle;
  final void Function(String?)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? isStartTime;
  final Widget? suffix;
  final BoxShadow? shadow;
  final String? hintText;
  final String? labelText;
  final Color? labelColor;
  final Color? floatingLabelColor;
  final Color? titleColor;
  final int? maxTextLength;
  final Color? cursorColor;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textAction;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? inputBorder;
  final int? maxLine;
  final int? minLine;
  final FocusNode? focusNode;
  final double? fontSize;
  final void Function(String?)? onSaved;
  final double? contentHeight;
  final double? contentWidth;
  final double? borderRadius;
  final Color? fillColor;
  final bool isFilled;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final BorderSide? borderSide;
  final TextAlignVertical? textAlignVertical;
  final Widget? prefix;
  final bool? isDense;
  final BoxConstraints? prefixIconConstraints;
  final String? subTitle;
  final bool? autofocus;
  final BoxConstraints? suffixIconConstraints;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;
  final Color? textColor;
  final AutovalidateMode? autovalidateMode;
  final List<String>? dropdownItems;
  final String? dropdownValue;
  final void Function(String?)? onDropdownChanged;
  final bool showCompareTextField;
  final double? horizontalLabelWidth;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isFocused = ValueNotifier(false);
  String? _selectedDropdownValue;

  @override
  void initState() {
    super.initState();
    _selectedDropdownValue = widget.dropdownValue;
    if (widget.focusNode == null) {
      _focusNode.addListener(() {
        _isFocused.value = _focusNode.hasFocus;
      });
    } else {
      widget.focusNode!.addListener(() {
        _isFocused.value = widget.focusNode!.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(AppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dropdownValue != oldWidget.dropdownValue) {
      _selectedDropdownValue = widget.dropdownValue;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if this should be a dropdown
    final bool isDropdown = widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty;

    // Horizontal label layout (icon + label on left, input on right)
    if (widget.showCompareTextField) {
      return Row(
        children: [
          Expanded(
            child: isDropdown ? _buildHorizontalDropdown(context) : _buildHorizontalTextField(context),
          ),
        ],
      );
    }

    // Original vertical layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Row(
            children: [

              Text(
                '  ${widget.title}',
                style:
                    widget.titleStyle ??
                    context.textTheme.titleSmall!.copyWith(
                      overflow: TextOverflow.ellipsis,
                       fontSize: AppSize.sp17
                    ),
              ),
              if (widget.subTitle != null) SizedBox(width: AppSize.w6) else const SizedBox(),
              if (widget.subTitle != null)
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppSize.w10),
                    child: Text(
                      widget.subTitle!,
                      style:
                          widget.titleStyle ??
                          context.textTheme.titleMedium!.copyWith(
                            fontSize: AppSize.sp11,
                            fontWeight: FontWeight.w500,
                            color: context.themeTextColors.descriptionColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        if (widget.title != null) SizedBox(height: AppSize.h12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w6),
          child: isDropdown ? _buildDropdown(context) : _buildTextField(context),
        ),
      ],
    );
  }

  // Dropdown widget
  Widget _buildDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? AppSize.r12),
        boxShadow: widget.fillColor != null ? null : [
          widget.shadow ??
          BoxShadow(
            color: Color(0xffFF8F4A).withValues(alpha: 0.25),
            blurRadius: AppSize.r24,
            spreadRadius: AppSize.sp1,
            // offset: Offset(0, AppSize.h2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDropdownMenu(context),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? AppSize.r12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.contentWidth ?? AppSize.w20,
            vertical: widget.contentHeight ?? AppSize.h16,
          ),
          decoration: BoxDecoration(
            color: widget.fillColor ?? context.themeColors.whiteColor,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? AppSize.r12),
            border: widget.borderSide != null
                ? Border.all(
                    color: widget.borderSide!.color,
                    width: widget.borderSide!.width,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedDropdownValue ?? widget.hintText ?? '',
                  style: _selectedDropdownValue != null
                      ? (widget.style ??
                          context.textTheme.titleSmall?.copyWith(
                            color: widget.textColor ,
                            fontSize: AppSize.sp16,
                          ))
                      : (widget.hintStyle ??
                      context.textTheme.titleSmall?.copyWith(
                        color: widget.textColor ?? Color(0xffAAA9A8),
                        fontSize: AppSize.sp16,
                      )),
                ),
              ),
              Icon(
                Icons.arrow_drop_down_outlined,
                color: context.themeTextColors.textColor,
                size: AppSize.sp30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDropdownMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + AppSize.w60, // Left position
        offset.dy + size.height, // Top position (below the field)
        screenWidth - offset.dx - size.width + AppSize.w6, // Right position
        0, // Bottom (not used)
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.r12),
      ),
      color: context.themeColors.whiteColor,
      elevation: 8,
      items: widget.dropdownItems!.map((String item) {
        final isSelected = item == _selectedDropdownValue;
        return PopupMenuItem<String>(
          value: item,
          height: AppSize.h35,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.w12,
              vertical: AppSize.h8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xffF8F8F8)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSize.r8),
            ),
            child: Text(
              item,
              style: context.textTheme.titleSmall?.copyWith(
                // fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: context.themeTextColors.textColor,
                fontSize: AppSize.sp12,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedDropdownValue = value;
        });
        if (widget.onDropdownChanged != null) {
          widget.onDropdownChanged!(value);
        }
      }
    });
  }

  // Original TextField widget (unchanged)
  Widget _buildTextField(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isFocused,
      builder: (context, isFocused, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? AppSize.r36),
            border: Border.all(color: Color(0xffE2E8F0)),
            boxShadow: widget.fillColor != null
                ? null
                : [
              widget.shadow ??
                  BoxShadow(
                    color:
                      Color(0xff000000).withValues(alpha: 0.1),
                    offset: Offset(0, 4),
                    blurRadius: AppSize.r6,
                    spreadRadius: -AppSize.sp4,
                  ),
            ],
          ),
          child: TextFormField(
                focusNode: widget.focusNode ?? _focusNode,
                controller: widget.controller,
                keyboardType: widget.keyboardType ?? TextInputType.number,
                maxLength: widget.maxTextLength,
                cursorColor: widget.cursorColor ?? context.themeColors.primary,
                validator: widget.validator,
                textInputAction: widget.textAction,
                onChanged: widget.onChanged,
                readOnly: widget.readOnly,
                obscureText: widget.obscureText,
                onTap: widget.onTap,
                onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                onSaved: widget.onSaved,
                maxLines: widget.maxLine,
                inputFormatters: widget.inputFormatters,
                textAlignVertical: widget.textAlignVertical ?? TextAlignVertical.center,
                textAlign: widget.textAlign,
                autofocus: widget.autofocus ?? false,
                autofillHints: widget.autofillHints,
                minLines: widget.minLine,

                style:
                    widget.style ??
                    context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: widget.textColor ?? context.themeTextColors.textColor,
                      fontSize: AppSize.sp18,
                    ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.contentWidth ?? AppSize.w20,
                    vertical: widget.contentHeight ?? AppSize.h16,
                  ),
                  errorMaxLines: 3,
                  counterText: '',
                  prefixIconConstraints: widget.prefixIconConstraints,
                  suffixIconConstraints: widget.suffixIconConstraints ?? BoxConstraints(minWidth: AppSize.w40),
                  isDense: widget.isDense ?? false,
                  border:
                      widget.inputBorder ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(widget.borderRadius ?? AppSize.r36),
                        borderSide: widget.borderSide ?? BorderSide.none,
                      ),
                  prefixIcon: widget.prefixIcon == null
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(left: AppSize.w14, right: AppSize.w8),
                          child: widget.prefixIcon,
                        ),
                  prefix: widget.prefix == null
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(right: AppSize.w8),
                          child: widget.prefix,
                        ),
                  suffix: widget.suffix == null
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(left: AppSize.w8),
                          child: widget.suffix,
                        ),
                  suffixIcon: widget.suffixIcon == null
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(right: AppSize.w16),
                          child: widget.suffixIcon,
                        ),
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  floatingLabelStyle: TextStyle(
                    fontSize: widget.fontSize ?? AppSize.sp14,
                    color: widget.floatingLabelColor ?? context.themeTextColors.textColor,
                  ),
                  labelStyle: TextStyle(
                    fontSize: widget.fontSize ?? AppSize.sp16,
                    fontWeight: FontWeight.w400,
                    color: widget.labelColor ?? context.themeTextColors.hintTextColor,
                  ),
                  hintStyle:
                      widget.hintStyle ??
                      context.textTheme.titleSmall?.copyWith(
                         color: widget.textColor ?? Color(0xffAAA9A8),
                        fontSize: AppSize.sp14,
                      ),
                  errorStyle: TextStyle(color: Colors.red, fontSize: AppSize.sp12),

                  filled: widget.isFilled,
                  fillColor: widget.fillColor ?? context.themeColors.whiteColor,
                ),
          ),
        );
      },
    );
  }

  // Horizontal TextField (no outer container/shadow)
  Widget _buildHorizontalTextField(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode ?? _focusNode,
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      maxLength: widget.maxTextLength,
      cursorColor: widget.cursorColor ?? context.themeColors.primary,
      validator: widget.validator,
      textInputAction: widget.textAction,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      onTap: widget.onTap,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onSaved: widget.onSaved,
      maxLines: widget.maxLine,
      inputFormatters: widget.inputFormatters,
      textAlignVertical: widget.textAlignVertical ?? TextAlignVertical.center,
      textAlign: widget.textAlign,
      autofocus: widget.autofocus ?? false,
      autofillHints: widget.autofillHints,
      minLines: widget.minLine,
      style: widget.style ??
          context.textTheme.titleSmall?.copyWith(
             color: Color(0xff504F4D),
            fontSize: AppSize.sp14,
          ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSize.w10,vertical: AppSize.h6),
        counterText: '',
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ??
            context.textTheme.titleSmall?.copyWith(
              color: Color(0xffAAA9A8),
              fontSize: AppSize.sp14,
            ),
        suffixIcon: widget.suffixIcon,
        suffixIconConstraints: widget.suffixIconConstraints,
        fillColor: context.themeColors.primary.withValues(alpha: 0.04),
        filled: true
       ),
    );
  }

  // Horizontal Dropdown (no outer container/shadow)
  Widget _buildHorizontalDropdown(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w12,vertical: AppSize.h5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? AppSize.r5),
       color: context.themeColors.primary.withValues(alpha: 0.04)
      ),
      child: InkWell(
        onTap: () => _showDropdownMenu(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedDropdownValue ?? widget.hintText ?? '',
                style: _selectedDropdownValue != null
                    ? (widget.style ??
                        context.textTheme.titleSmall?.copyWith(
                          color: Color(0xff504F4D),
                          fontSize: AppSize.sp16,
                        ))
                    : (widget.hintStyle ??
                        context.textTheme.titleSmall?.copyWith(
                          color: Color(0xffAAA9A8),
                          fontSize: AppSize.sp14,
                        )),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_outlined,
              color: context.themeTextColors.textColor,
              size: AppSize.sp24,
            ),
          ],
        ),
      ),
    );
  }
}
