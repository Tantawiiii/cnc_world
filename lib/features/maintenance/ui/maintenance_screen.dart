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
  File? _selectedMedia;
  MediaType? _mediaType;
  int? _imageId;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  List<Engineer> _engineers = [];
  bool _isLoadingEngineers = true;
  String? _engineersError;

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
      final result = await context.pickMedia();
      if (result != null && mounted) {
        setState(() {
          _selectedMedia = result.file;
          _mediaType = result.type;
          _isUploadingImage = true;
        });
        context.read<MaintenanceCubit>().uploadImage(result.file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTexts.errorPickingMedia} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _submitMaintenance() {
    if (!_formKey.currentState!.validate()) return;
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
      engineerId: _selectedEngineer?.id,
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
                if (state is EngineersLoaded) {
                  setState(() {
                    _engineers = state.engineers;
                    _isLoadingEngineers = false;
                  });
                } else if (state is EngineersError) {
                  setState(() {
                    _isLoadingEngineers = false;
                    _engineersError = state.message;
                  });
                } else if (state is ImageUploading) {
                  setState(() {
                    _isUploadingImage = true;
                    _uploadProgress = (state as ImageUploading).progress;
                  });
                } else if (state is ImageUploaded) {
                  setState(() {
                    _imageId = state.imageId;
                    _isUploadingImage = false;
                    _uploadProgress = 1.0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppTexts.imageUploadSuccess),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (state is ImageUploadError) {
                  setState(() {
                    _isUploadingImage = false;
                    _uploadProgress = 0.0;
                  });
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
                      _buildEngineerDropdownWidget(),
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

  Widget _buildEngineerDropdownWidget() {
    if (_isLoadingEngineers) {
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
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_engineersError != null) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.error, width: 1),
        ),
        child: Text(
          _engineersError!,
          style: TextStyle(fontSize: 14.sp, color: AppColors.error),
        ),
      );
    }

    if (_engineers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.warning, width: 1),
        ),
        child: Text(
          AppTexts.noEngineersAvailable,
          style: TextStyle(fontSize: 14.sp, color: AppColors.warning),
        ),
      );
    }

    return _buildEngineerDropdown(_engineers);
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
        child: _selectedMedia != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: _mediaType == MediaType.video
                        ? Container(
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_filled,
                                    size: 64.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    AppTexts.video,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Image.file(_selectedMedia!, fit: BoxFit.cover),
                  ),
                  if (_isUploadingImage)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60.w,
                              height: 60.w,
                              child: CircularProgressIndicator(
                                value: _uploadProgress > 0
                                    ? _uploadProgress
                                    : null,
                                color: AppColors.primary,
                                strokeWidth: 4,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              AppTexts.maintenanceUploadingImage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
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
