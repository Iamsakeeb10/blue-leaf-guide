// lib/app/widgets/modern_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/utils/sizes.dart';

class TextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final VoidCallback? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final String? prefixIconSvg; // NEW - for SVG path
  final String? suffixIconSvg; // NEW - for SVG path
  final Widget? prefixIconWidget; // For custom widget

  const TextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIconSvg,
    this.prefixIconWidget,
    this.suffixIconSvg,
  });

  @override
  State<TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            enabled: widget.enabled,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            onChanged: widget.onChanged != null
                ? (_) => widget.onChanged!()
                : null,
            onEditingComplete: widget.onEditingComplete,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.textPrimary.withOpacity(0.3),
                fontSize: AppFontSize.s14,
                fontWeight: FontWeight.w500,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 16.w + 20.r + 8.w,
                minHeight: 12.h + 20.r + 12.h,
              ),
              prefixIcon:
                  (widget.prefixIconWidget != null ||
                      widget.prefixIconSvg != null ||
                      widget.icon != null)
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 8.w,
                        top: 12.h,
                        bottom: 12.h,
                      ),
                      child: _buildPrefixIcon(),
                    )
                  : null,

              suffixIconConstraints: BoxConstraints(
                minWidth: 8.w + 20.r + 16.w,
                minHeight: 12.h + 20.r + 12.h,
              ),
              suffixIcon:
                  (widget.suffixIconSvg != null || widget.suffixIcon != null)
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: 8.w,
                        right: 16.w,
                        top: 12.h,
                        bottom: 12.h,
                      ),
                      child: _buildSuffixIcon(),
                    )
                  : null,

              filled: true,
              fillColor: widget.enabled
                  ? AppColors.background.withOpacity(0.5)
                  : AppColors.background.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.r),
                borderSide: BorderSide(
                  color: AppColors.neutral10.withOpacity(0.05),
                  width: 1.25.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.25.w),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.r),
                borderSide: BorderSide(color: AppColors.danger, width: 1.25.w),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.r),
                borderSide: BorderSide(color: AppColors.danger, width: 1.25.w),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.r),
                borderSide: BorderSide(
                  color: AppColors.tint.withOpacity(0.2),
                  width: 1.25.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppPadding.p16,
                vertical: 16.h,
              ),
              errorStyle: TextStyle(
                fontSize: AppFontSize.s12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrefixIcon() {
    if (widget.prefixIconWidget != null) {
      return SizedBox(
        width: 20.r,
        height: 20.r,
        child: widget.prefixIconWidget,
      );
    }

    if (widget.prefixIconSvg != null) {
      return SvgPicture.asset(
        widget.prefixIconSvg!,
        width: 20.r,
        height: 20.r,
        colorFilter: ColorFilter.mode(
          _isFocused ? AppColors.primary : AppColors.textSecondary,
          BlendMode.srcIn,
        ),
      );
    }

    return Icon(
      widget.icon,
      size: 20.r,
      color: _isFocused ? AppColors.primary : AppColors.textSecondary,
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.suffixIconSvg != null) {
      return SvgPicture.asset(
        widget.suffixIconSvg!,
        width: 20.r,
        height: 20.r,
        colorFilter: ColorFilter.mode(
          _isFocused ? AppColors.primary : AppColors.textSecondary,
          BlendMode.srcIn,
        ),
      );
    }

    return SizedBox(width: 20.r, height: 20.r, child: widget.suffixIcon);
  }
}
