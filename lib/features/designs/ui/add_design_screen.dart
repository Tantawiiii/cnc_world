import 'dart:io';
import 'package:bounce/bounce.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/extensions/image_picker_extension.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/design_cubit.dart';
import '../cubit/design_state.dart';
import '../data/models/design_models.dart';
import '../data/repositories/design_repository.dart';

class AddDesignScreen extends StatefulWidget {
  const AddDesignScreen({super.key});

  @override
  State<AddDesignScreen> createState() => _AddDesignScreenState();
}

class _AddDesignScreenState extends State<AddDesignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  File? _selectedFile;
  String? _selectedFileName;
  int? _imageId;
  int? _fileId;
  bool _isUploadingImage = false;
  bool _isUploadingFile = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
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
        try {
          final imageId = await context.read<DesignCubit>().uploadImage(
            result.file,
          );
          if (mounted) {
            setState(() {
              _imageId = imageId;
              _isUploadingImage = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.imageUploadSuccess),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUploadingImage = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppTexts.imageUploadFailedWithError} $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTexts.imageSelectionError} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null && mounted) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.single.name;
          _isUploadingFile = true;
        });
        try {
          final fileId = await context.read<DesignCubit>().uploadFile(file);
          if (mounted) {
            setState(() {
              _fileId = fileId;
              _isUploadingFile = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.fileUploadSuccess),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUploadingFile = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppTexts.fileUploadFailed} $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingFile = false);
        print('خطأ في اختيار الملف: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTexts.fileSelectionError} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _submitDesign(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_imageId == null || _fileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.imageAndFileRequired),
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

    final request = AddDesignRequest(
      name: _nameController.text.trim(),
      price: price,
      active: 1,
      file: _fileId,
      image: _imageId,
    );

    print(
      'AddDesignScreen: Calling addDesign with request: ${request.toJson()}',
    );
    context.read<DesignCubit>().addDesign(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DesignCubit(DesignRepository()),
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
                child: BlocConsumer<DesignCubit, DesignState>(
                  listenWhen: (previous, current) {
                    // Only listen to upload states
                    return current is DesignUploaded ||
                        current is DesignUploadError;
                  },
                  listener: (context, state) {
                    print(
                      'AddDesignScreen: BlocConsumer listener received state: ${state.runtimeType}',
                    );
                    if (state is DesignUploaded) {
                      print(
                        'AddDesignScreen: DesignUploaded detected, showing toast',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppTexts.designAddedSuccess),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      // Go back after showing toast with success result
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          print('AddDesignScreen: Navigating back');
                          Navigator.of(context).pop(true);
                        }
                      });
                    } else if (state is DesignUploadError) {
                      print(
                        'AddDesignScreen: DesignUploadError detected: ${state.message}',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
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
                                    AppTexts.addDesign,
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
                              AppTexts.designName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            AppTextField(
                              controller: _nameController,
                              hint: AppTexts.designNameHint,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppTexts.designNameRequired;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24.h),

                            // Price
                            Text(
                              AppTexts.price,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            AppTextField(
                              controller: _priceController,
                              hint: AppTexts.priceHint,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppTexts.priceRequired;
                                }
                                if (double.tryParse(value.trim()) == null) {
                                  return AppTexts.invalidPrice;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24.h),

                            // Image
                            Text(
                              AppTexts.designImage,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildImageUploadSection(),
                            SizedBox(height: 24.h),

                            // File
                            Text(
                              AppTexts.designFile,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildFileUploadSection(),
                            SizedBox(height: 32.h),

                            // Submit Button
                            PrimaryButton(
                              title: AppTexts.addDesignButton,
                              onPressed: state is DesignUploading
                                  ? null
                                  : () {
                                      print(
                                        'AddDesignScreen: Submit button pressed',
                                      );
                                      _submitDesign(context);
                                    },
                              isLoading: state is DesignUploading,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

  Widget _buildFileUploadSection() {
    return Bounce(
      onTap: _isUploadingFile ? null : _pickFile,
      child: Container(
        width: double.infinity,
        height: 120.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _fileId != null ? AppColors.success : AppColors.border,
            width: _fileId != null ? 2 : 1.5,
          ),
        ),
        child: _isUploadingFile
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 12.h),
                    Text(
                      AppTexts.uploadingFile,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              )
            : _fileId != null
            ? Padding(
                padding: EdgeInsets.all(12.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 28.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppTexts.fileUploadSuccess,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedFileName != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          _selectedFileName!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_file,
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
