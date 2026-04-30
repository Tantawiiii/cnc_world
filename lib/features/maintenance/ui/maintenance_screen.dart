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
import '../../engineers/cubit/engineer_cubit.dart';
import '../../engineers/cubit/engineer_state.dart';
import '../../engineers/data/models/engineer_models.dart' as engineer_models;
import '../../engineers/data/repositories/engineer_repository.dart';
import '../cubit/maintenance_cubit.dart';
import '../cubit/maintenance_state.dart' hide EngineersLoaded, EngineersError;
import '../data/models/maintenance_models.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemDetailsController = TextEditingController();

  engineer_models.Engineer? _selectedEngineer;
  File? _selectedMedia;
  MediaType? _mediaType;
  int? _imageId;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
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
    return BlocProvider(
      create: (_) => EngineerCubit(EngineerRepository())..loadEngineers(),
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
              child: BlocListener<MaintenanceCubit, MaintenanceState>(
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
      ),
    );
  }

  Widget _buildEngineerDropdownWidget() {
    return BlocBuilder<EngineerCubit, EngineerState>(
      builder: (context, state) {
        final isLoading = state is EngineersLoading && state is! EngineersLoadingMore;
        final errorState = state is EngineersError ? state : null;
        final engineers = state is EngineersLoaded
            ? state.engineers
            : <engineer_models.Engineer>[];

        if (isLoading) {
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

        if (errorState != null) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.error, width: 1),
            ),
            child: Text(
              errorState.message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
            ),
          );
        }

        if (engineers.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.warning, width: 1),
            ),
            child: Text(
              AppTexts.noEngineersAvailable,
              style: TextStyle(fontSize: 14.sp, color: AppColors.warning),
            ),
          );
        }

        return _buildEngineerPicker(context, engineers);
      },
    );
  }

  Widget _buildEngineerPicker(
    BuildContext providerContext,
    List<engineer_models.Engineer> engineers,
  ) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _showEngineerSelectionSheet(providerContext),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(Icons.engineering, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: _selectedEngineer == null
                    ? Text(
                        AppTexts.selectEngineer,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 15.sp,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedEngineer!.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${_selectedEngineer!.rating.toStringAsFixed(1)} ${AppTexts.reviews} (${_selectedEngineer!.totalReviews})',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
              Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEngineerSelectionSheet(BuildContext providerContext) async {
    final engineerCubit = providerContext.read<EngineerCubit>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String query = '';
        return BlocProvider.value(
          value: engineerCubit,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TextField(
                        onChanged: (value) {
                          setModalState(() => query = value.trim().toLowerCase());
                        },
                        decoration: InputDecoration(
                          hintText: '${AppTexts.selectEngineer}...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: BlocBuilder<EngineerCubit, EngineerState>(
                        builder: (context, state) {
                          final allEngineers = state is EngineersLoaded
                              ? state.engineers
                              : <engineer_models.Engineer>[];
                          final hasMore = state is EngineersLoaded && state.hasMore;
                          final isLoadingMore = state is EngineersLoadingMore;

                          final filtered = allEngineers.where((engineer) {
                            if (query.isEmpty) return true;
                            return engineer.name.toLowerCase().contains(query) ||
                                engineer.phone.toLowerCase().contains(query);
                          }).toList();

                          return NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification.metrics.pixels >=
                                      notification.metrics.maxScrollExtent * 0.8 &&
                                  hasMore &&
                                  !isLoadingMore) {
                                context.read<EngineerCubit>().loadMoreEngineers();
                              }
                              return false;
                            },
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: filtered.length + (hasMore ? 1 : 0),
                              separatorBuilder: (_, __) => SizedBox(height: 8.h),
                              itemBuilder: (context, index) {
                                if (index >= filtered.length) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10.h),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                }

                                final engineer = filtered[index];
                                final isSelected = _selectedEngineer?.id == engineer.id;

                                return Material(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: () {
                                      setState(() => _selectedEngineer = engineer);
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: AppColors.primary,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  engineer.name,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 13.sp,
                                                      color: AppColors.warning,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      '${engineer.rating.toStringAsFixed(1)} (${engineer.totalReviews})',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  if (query.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                      child: Builder(
                        builder: (context) {
                          final state = context.watch<EngineerCubit>().state;
                          final allEngineers = state is EngineersLoaded
                              ? state.engineers
                              : <engineer_models.Engineer>[];
                          final hasMatch = allEngineers.any(
                            (engineer) =>
                                engineer.name.toLowerCase().contains(query) ||
                                engineer.phone.toLowerCase().contains(query),
                          );
                          if (hasMatch) return const SizedBox.shrink();
                          return Text(
                            AppTexts.noEngineersAvailable,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
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
                        color: Colors.black.withValues(alpha: 0.7),
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
