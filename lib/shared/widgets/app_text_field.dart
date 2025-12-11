import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.obscurable = false,
    this.keyboardType,
    this.leadingIcon,
    this.iconColor,
    this.validator,
    this.maxLines,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool obscurable;
  final TextInputType? keyboardType;
  final IconData? leadingIcon;
  final Color? iconColor;
  final String? Function(String?)? validator;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        maxLines: _obscureText ? 1 : widget.maxLines,
        inputFormatters: widget.inputFormatters,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15.sp),
          filled: true,
          fillColor: _isFocused ? AppColors.surface : AppColors.surfaceVariant,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          prefixIcon: widget.leadingIcon == null
              ? null
              : Icon(
                  widget.leadingIcon,
                  color: _isFocused
                      ? AppColors.primary
                      : (widget.iconColor ?? AppColors.textSecondary),
                  size: 22.sp,
                ),
          suffixIcon: widget.obscurable
              ? IconButton(
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 22.sp,
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(14.r),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 1.5),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 2),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
