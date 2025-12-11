import 'dart:io';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/extensions/image_picker_extension.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/maintenance_cubit.dart';
import '../cubit/maintenance_state.dart';
import '../data/models/maintenance_models.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemDetailsController = TextEditingController();

  Engineer? _selectedEngineer;
  File? _selectedImage;
  int? _imageId;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    context.read<MaintenanceCubit>().loadEngineers();
  }

  @override
  void dispose() {
    _problemDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await context.pickAndCropImage();
      if (result != null && mounted) {
        setState(() {
          _selectedImage = result.file;
          _isUploadingImage = true;
        });
        context.read<MaintenanceCubit>().uploadImage(result.file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _submitMaintenance() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEngineer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.engineerRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_imageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.maintenanceImageRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final request = MaintenanceRequest(
      problemDetails: _problemDetailsController.text.trim(),
      engineerId: _selectedEngineer!.id,
      assignedBy: 'user',
      image: _imageId!,
    );

    context.read<MaintenanceCubit>().submitMaintenance(request);
  }

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
            child: BlocListener<MaintenanceCubit, MaintenanceState>(
              listener: (context, state) {
                if (state is ImageUploaded) {
                  setState(() {
                    _imageId = state.imageId;
                    _isUploadingImage = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppTexts.imageUploadSuccess),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (state is ImageUploadError) {
                  setState(() => _isUploadingImage = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else if (state is MaintenanceSubmitted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppTexts.maintenanceSuccess),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.of(context).pop();
                } else if (state is MaintenanceSubmitError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              AppTexts.maintenanceTitle,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      Text(
                        AppTexts.problemDetails,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      AppTextField(
                        controller: _problemDetailsController,
                        hint: AppTexts.problemDetailsHint,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppTexts.problemDetailsRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      Text(
                        AppTexts.selectEngineer,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      BlocBuilder<MaintenanceCubit, MaintenanceState>(
                        builder: (context, state) {
                          if (state is MaintenanceLoading) {
                            return Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    AppTexts.loadingEngineers,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is EngineersLoaded) {
                            if (state.engineers.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: AppColors.warning,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  AppTexts.noEngineersAvailable,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.warning,
                                  ),
                                ),
                              );
                            }
                            return _buildEngineerDropdown(state.engineers);
                          } else if (state is EngineersError) {
                            return Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: AppColors.error,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.error,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      SizedBox(height: 24.h),

                      Text(
                        AppTexts.uploadProblemImage,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildImageUploadSection(),
                      SizedBox(height: 32.h),

                      BlocBuilder<MaintenanceCubit, MaintenanceState>(
                        builder: (context, state) {
                          final isSubmitting = state is MaintenanceSubmitting;
                          return PrimaryButton(
                            title: AppTexts.submitMaintenance,
                            onPressed: isSubmitting ? null : _submitMaintenance,
                            isLoading: isSubmitting,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEngineerDropdown(List<Engineer> engineers) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _selectedEngineer != null
              ? AppColors.primary
              : AppColors.border,
          width: _selectedEngineer != null ? 2 : 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Engineer>(
          value: _selectedEngineer,
          isExpanded: true,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          hint: Text(
            AppTexts.selectEngineer,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 15.sp),
          ),
          items: engineers.map((engineer) {
            return DropdownMenuItem<Engineer>(
              value: engineer,
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          engineer.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          engineer.phone,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (Engineer? engineer) {
            setState(() => _selectedEngineer = engineer);
          },
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Bounce(
      onTap: _isUploadingImage ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _imageId != null ? AppColors.success : AppColors.border,
            width: _imageId != null ? 2 : 1.5,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                  if (_isUploadingImage)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 12.h),
                            Text(
                              AppTexts.maintenanceUploadingImage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppTexts.tapToSelect,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
