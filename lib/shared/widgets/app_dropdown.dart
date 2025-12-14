import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constant/app_colors.dart';

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.leadingIcon,
    this.validator,
    this.enabled = true,
  });

  final String hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final T? value;
  final IconData? leadingIcon;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: FormField<T>(
        initialValue: widget.value,
        validator: widget.validator,
        builder: (FormFieldState<T> field) {
          return InputDecorator(
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
                          : AppColors.textSecondary,
                      size: 22.sp,
                    ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: _isFocused
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24.sp,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: field.hasError
                      ? AppColors.error
                      : (_isFocused
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.border),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: field.hasError ? AppColors.error : AppColors.primary,
                  width: 2,
                ),
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
              errorText: field.errorText,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: widget.value,
                isDense: true,
                isExpanded: true,
                items: widget.items,
                onChanged: widget.enabled
                    ? (T? newValue) {
                        widget.onChanged(newValue);
                        field.didChange(newValue);
                      }
                    : null,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                icon: const SizedBox.shrink(),
                dropdownColor: AppColors.surface,
              ),
            ),
          );
        },
      ),
    );
  }
}

