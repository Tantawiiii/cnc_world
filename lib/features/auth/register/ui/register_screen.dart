import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/extensions/image_picker_extension.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/register_cubit.dart';
import '../data/models/register_models.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole? role;

  const RegisterScreen({super.key, this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _workshopNameController = TextEditingController();
  final _natureOfWorkController = TextEditingController();
  final _facebookLinkController = TextEditingController();
  final _whatsappNumberController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  File? _selectedImage;
  int? _imageId;
  bool _isUploadingImage = false;

  UserRole get selectedRole => widget.role ?? UserRole.user;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _workshopNameController.dispose();
    _natureOfWorkController.dispose();
    _facebookLinkController.dispose();
    _whatsappNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final result = await context.pickAndCropImage();

      if (result != null && mounted) {
        setState(() => _isUploadingImage = true);
        final file = result.file;

        if (mounted) {
          setState(() => _selectedImage = file);
          final cubit = context.read<RegisterCubit>();
          final uploadedImageId = await cubit.uploadImage(file);

          if (uploadedImageId != null && mounted) {
            setState(() {
              _imageId = uploadedImageId;
              _isUploadingImage = false;
            });
          } else if (mounted) {
            setState(() => _isUploadingImage = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.imageUploadFailed),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _handleRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_needsImage() && _imageId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.imageRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final request = RegisterRequest(
        role: selectedRole,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        address: _needsAddress() ? _addressController.text.trim() : null,
        city: _needsAddress() ? _cityController.text.trim() : null,
        state: _needsAddress() ? _stateController.text.trim() : null,
        workshopName: _needsWorkshopName()
            ? _workshopNameController.text.trim()
            : null,
        natureOfWork: _needsNatureOfWork()
            ? _natureOfWorkController.text.trim()
            : null,
        facebookLink: _needsSocialLinks()
            ? _facebookLinkController.text.trim()
            : null,
        whatsappNumber: _needsSocialLinks()
            ? _whatsappNumberController.text.trim()
            : null,
        imageId: _needsImage() ? _imageId : null,
      );

      context.read<RegisterCubit>().register(request);
    }
  }

  bool _needsAddress() =>
      selectedRole == UserRole.user || selectedRole == UserRole.seller;
  bool _needsWorkshopName() => selectedRole == UserRole.seller;
  bool _needsNatureOfWork() => selectedRole == UserRole.seller;
  bool _needsSocialLinks() => selectedRole == UserRole.merchant;
  bool _needsImage() =>
      selectedRole == UserRole.seller || selectedRole == UserRole.merchant;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.background, AppColors.backgroundLight],
            ),
          ),
          child: SafeArea(
            child: BlocProvider(
              create: (context) => RegisterCubit(),
              child: BlocListener<RegisterCubit, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterSuccess) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppTexts.registerSuccess),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  } else if (state is RegisterError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(12.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.textPrimary,
                                  size: 24.sp,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            Text(
                              AppTexts.registerTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                foreground: Paint()
                                  ..shader = AppColors.brandGradient
                                      .createShader(
                                        const Rect.fromLTWH(
                                          0.0,
                                          0.0,
                                          200.0,
                                          70.0,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.secondaryGradient,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  _getRoleTitle(selectedRole),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),

                            if (_needsImage()) ...[
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 400),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.9 + (value * 0.1),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Builder(
                                  builder: (builderContext) => GestureDetector(
                                    onTap: _isUploadingImage
                                        ? null
                                        : () => _pickImage(builderContext),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      height: 150.h,
                                      decoration: BoxDecoration(
                                        gradient: _selectedImage != null
                                            ? null
                                            : LinearGradient(
                                                colors: [
                                                  AppColors.primary.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  AppColors.accent.withValues(
                                                    alpha: 0.05,
                                                  ),
                                                ],
                                              ),
                                        color: _selectedImage != null
                                            ? AppColors.surfaceVariant
                                            : null,
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        border: Border.all(
                                          color: _selectedImage != null
                                              ? AppColors.primary
                                              : AppColors.primary.withValues(
                                                  alpha: 0.3,
                                                ),
                                          width: _selectedImage != null
                                              ? 2.5
                                              : 2,
                                        ),
                                        boxShadow: _selectedImage != null
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: _isUploadingImage
                                          ? Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    color: AppColors.primary,
                                                  ),
                                                  SizedBox(height: 12.h),
                                                  Text(
                                                    AppTexts.uploadingImage,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : _selectedImage != null
                                          ? Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        18.r,
                                                      ),
                                                  child: Image.file(
                                                    _selectedImage!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8.h,
                                                  left: 8.w,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                      8.w,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.check,
                                                      size: 20.sp,
                                                      color: AppColors
                                                          .textOnPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8.h,
                                                  right: 8.w,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedImage = null;
                                                        _imageId = null;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        8.w,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.error,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 20.sp,
                                                        color: AppColors
                                                            .textOnPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(16.w),
                                                  decoration: BoxDecoration(
                                                    gradient: AppColors
                                                        .primaryGradient,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .add_photo_alternate_outlined,
                                                    size: 40.sp,
                                                    color:
                                                        AppColors.textOnPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 16.h),
                                                Text(
                                                  AppTexts.uploadImage,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  AppTexts.tapToSelect,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                            ],

                            AppTextField(
                              controller: _nameController,
                              hint: AppTexts.name,
                              leadingIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppTexts.nameRequired;
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 12.h),

                            AppTextField(
                              controller: _phoneController,
                              hint: AppTexts.phone,
                              keyboardType: TextInputType.phone,
                              leadingIcon: Icons.phone_outlined,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppTexts.phoneRequired;
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 12.h),

                            AppTextField(
                              controller: _passwordController,
                              hint: AppTexts.password,
                              obscure: true,
                              obscurable: true,
                              leadingIcon: Icons.lock_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppTexts.passwordRequired;
                                }
                                return null;
                              },
                            ),

                            if (_needsAddress()) ...[
                              SizedBox(height: 12.h),
                              AppTextField(
                                controller: _addressController,
                                hint: AppTexts.address,
                                leadingIcon: Icons.location_on_outlined,
                                validator: _needsAddress()
                                    ? (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppTexts.addressRequired;
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              AppTextField(
                                controller: _cityController,
                                hint: AppTexts.city,
                                leadingIcon: Icons.apartment_outlined,
                                validator: _needsAddress()
                                    ? (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppTexts.cityRequired;
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              AppTextField(
                                controller: _stateController,
                                hint: AppTexts.state,
                                leadingIcon: Icons.map_outlined,
                                validator: _needsAddress()
                                    ? (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppTexts.stateRequired;
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                            ],

                            if (_needsWorkshopName()) ...[
                              SizedBox(height: 12.h),
                              AppTextField(
                                controller: _workshopNameController,
                                hint: AppTexts.workshopName,
                                leadingIcon: Icons.store_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppTexts.workshopNameRequired;
                                  }
                                  return null;
                                },
                              ),
                            ],

                            if (_needsNatureOfWork()) ...[
                              SizedBox(height: 12.h),
                              AppTextField(
                                controller: _natureOfWorkController,
                                hint: AppTexts.natureOfWork,
                                leadingIcon: Icons.work_outline,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppTexts.natureOfWorkRequired;
                                  }
                                  return null;
                                },
                              ),
                            ],

                            if (_needsSocialLinks()) ...[
                              SizedBox(height: 12.h),
                              AppTextField(
                                controller: _facebookLinkController,
                                hint: AppTexts.facebookLink,
                                leadingIcon: Icons.facebook_outlined,
                                keyboardType: TextInputType.url,
                              ),
                              SizedBox(height: 12.h),
                              AppTextField(
                                controller: _whatsappNumberController,
                                hint: AppTexts.whatsappNumber,
                                keyboardType: TextInputType.phone,
                                leadingIcon: Icons.chat_bubble_outline,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ],

                            SizedBox(height: 40.h),
                            BlocBuilder<RegisterCubit, RegisterState>(
                              builder: (context, state) {
                                return PrimaryButton(
                                  title: AppTexts.registerButton,
                                  onPressed:
                                      state is RegisterLoading ||
                                          state is RegisterImageUploading
                                      ? null
                                      : () => _handleRegister(context),
                                  isLoading: state is RegisterLoading,
                                );
                              },
                            ),

                            SizedBox(height: 24.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppTexts.alreadyHaveAccount,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushReplacementNamed(AppRoutes.login),
                                  child: Text(
                                    AppTexts.backToLogin,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.user:
        return AppTexts.roleUser;
      case UserRole.engineer:
        return AppTexts.roleEngineer;
      case UserRole.seller:
        return AppTexts.roleSeller;
      case UserRole.merchant:
        return AppTexts.roleMerchant;
    }
  }
}
