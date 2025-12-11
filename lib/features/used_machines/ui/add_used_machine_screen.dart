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

  File? _selectedImage;
  int? _imageId;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
        context.read<UsedMachineCubit>().uploadImage(result.file);
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

  void _submitMachine() {
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

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.invalidPrice),
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

    context.read<UsedMachineCubit>().addUsedMachine(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsedMachineCubit(UsedMachineRepository()),
      child: Builder(
        builder: (context) => Directionality(
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
                    } else if (state is UsedMachineAdded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppTexts.machineAddedSuccess),
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
                                child: Text(
                                  AppTexts.addUsedMachine,
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

                          // Name
                          Text(
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
                            hint: AppTexts.machineNameHint,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.machineNameRequired;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24.h),

                          // Price
                          Text(
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
                            hint: AppTexts.machinePriceHint,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.machinePriceRequired;
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return AppTexts.invalidPrice;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24.h),

                          // Description
                          Text(
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
                            hint: AppTexts.machineDescriptionHint,
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.machineDescriptionRequired;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24.h),

                          // Image
                          Text(
                            AppTexts.uploadMachineImage,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildImageUploadSection(),
                          SizedBox(height: 32.h),

                          // Submit Button
                          BlocBuilder<UsedMachineCubit, UsedMachineState>(
                            builder: (context, state) {
                              final isAdding = state is AddingUsedMachine;
                              return PrimaryButton(
                                title: AppTexts.addMachine,
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
