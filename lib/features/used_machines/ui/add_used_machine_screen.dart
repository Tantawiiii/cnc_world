import 'dart:io';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/extensions/image_picker_extension.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/used_machine_cubit.dart';
import '../cubit/used_machine_state.dart';
import '../data/models/used_machine_models.dart';
import '../data/repositories/used_machine_repository.dart';

class AddUsedMachineScreen extends StatefulWidget {
  const AddUsedMachineScreen({super.key});

  @override
  State<AddUsedMachineScreen> createState() => _AddUsedMachineScreenState();
}

class _AddUsedMachineScreenState extends State<AddUsedMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedMedia;
  MediaType? _mediaType;
  int? _imageId;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  late final UsedMachineCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = UsedMachineCubit(UsedMachineRepository());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _cubit.close();
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
        _cubit.uploadImage(result.file);
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${localizations?.errorPickingMedia ?? AppTexts.errorPickingMedia} $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _submitMachine() {
    if (!_formKey.currentState!.validate()) return;
    if (_imageId == null) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.maintenanceImageRequired ??
                AppTexts.maintenanceImageRequired,
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.invalidPrice ?? AppTexts.invalidPrice),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final request = AddUsedMachineRequest(
      name: _nameController.text.trim(),
      price: price,
      description: _descriptionController.text.trim(),
      image: _imageId!,
    );

    _cubit.addUsedMachine(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
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
              child: BlocListener<UsedMachineCubit, UsedMachineState>(
                bloc: _cubit,
                listener: (context, state) {
                  if (state is ImageUploading) {
                    setState(() {
                      _isUploadingImage = true;
                      _uploadProgress = state.progress;
                    });
                  } else if (state is ImageUploaded) {
                    setState(() {
                      _imageId = state.imageId;
                      _isUploadingImage = false;
                      _uploadProgress = 1.0;
                    });
                    final localizations = AppLocalizations.of(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations?.imageUploadSuccess ??
                              AppTexts.imageUploadSuccess,
                        ),
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
                  } else if (state is UsedMachineAdded) {
                    final localizations = AppLocalizations.of(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations?.machineAddedSuccess ??
                              AppTexts.machineAddedSuccess,
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else if (state is AddUsedMachineError) {
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
                              child: Builder(
                                builder: (context) {
                                  final localizations = AppLocalizations.of(
                                    context,
                                  );
                                  return Text(
                                    localizations?.addUsedMachine ??
                                        AppTexts.addUsedMachine,
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Name
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations?.machineName ??
                                      AppTexts.machineName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                AppTextField(
                                  controller: _nameController,
                                  hint:
                                      localizations?.machineNameHint ??
                                      AppTexts.machineNameHint,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return localizations
                                              ?.machineNameRequired ??
                                          AppTexts.machineNameRequired;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 24.h),

                        // Price
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations?.machinePrice ??
                                      AppTexts.machinePrice,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                AppTextField(
                                  controller: _priceController,
                                  hint:
                                      localizations?.machinePriceHint ??
                                      AppTexts.machinePriceHint,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return localizations
                                              ?.machinePriceRequired ??
                                          AppTexts.machinePriceRequired;
                                    }
                                    if (double.tryParse(value.trim()) == null) {
                                      return localizations?.invalidPrice ??
                                          AppTexts.invalidPrice;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 24.h),

                        // Description
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations?.machineDescription ??
                                      AppTexts.machineDescription,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                AppTextField(
                                  controller: _descriptionController,
                                  hint:
                                      localizations?.machineDescriptionHint ??
                                      AppTexts.machineDescriptionHint,
                                  maxLines: 4,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return localizations
                                              ?.machineDescriptionRequired ??
                                          AppTexts.machineDescriptionRequired;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 24.h),

                        // Image
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations?.uploadMachineImage ??
                                      AppTexts.uploadMachineImage,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                _buildImageUploadSection(context),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 32.h),

                        // Submit Button
                        BlocBuilder<UsedMachineCubit, UsedMachineState>(
                          bloc: _cubit,
                          builder: (context, state) {
                            final isAdding = state is AddingUsedMachine;
                            final localizations = AppLocalizations.of(context);
                            return PrimaryButton(
                              title:
                                  localizations?.addMachine ??
                                  AppTexts.addMachine,
                              onPressed: isAdding ? null : _submitMachine,
                              isLoading: isAdding,
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
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
                                    localizations?.video ?? AppTexts.video,
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
                              localizations?.maintenanceUploadingImage ??
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
                    localizations?.tapToSelect ?? AppTexts.tapToSelect,
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
