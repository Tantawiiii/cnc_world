import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/design_cubit.dart';
import '../cubit/design_state.dart';
import '../data/models/design_models.dart';

class DesignsListScreen extends StatelessWidget {
  const DesignsListScreen({super.key});

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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
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
                          AppTexts.homeCategoryDesigns,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.addDesign);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocConsumer<DesignCubit, DesignState>(
                    listener: (context, state) {
                      if (state is DesignDownloaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.isFile
                                  ? AppTexts.fileDownloadSuccess
                                  : AppTexts.imageDownloadSuccess,
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (state is DesignDownloadError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.isFile
                                  ? '${AppTexts.fileDownloadFailed} ${state.message}'
                                  : '${AppTexts.imageDownloadFailed} ${state.message}',
                            ),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is DesignsLoading) {
                        return _buildShimmerList();
                      }

                      List<Design> designs = [];
                      if (state is DesignsLoaded) {
                        designs = state.designs;
                      } else if (state is DesignDownloading) {
                        designs = state.designs;
                      } else if (state is DesignDownloaded) {
                        designs = state.designs;
                      } else if (state is DesignDownloadError) {
                        designs = state.designs;
                      }

                      if (designs.isEmpty && state is! DesignsLoading) {
                        return Center(
                          child: Text(
                            AppTexts.noDesignsAvailable,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      if (state is DesignsError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<DesignCubit>().loadDesigns();
                                },
                                child: Text(AppTexts.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (designs.isNotEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<DesignCubit>().loadDesigns();
                          },
                          color: AppColors.primary,
                          child: ListView.separated(
                            key: ValueKey('designs_list_${designs.length}'),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            itemCount: designs.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              return _buildAnimatedDesignCard(
                                context,
                                designs[index],
                                index,
                              );
                            },
                            cacheExtent: 500,
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDesignCard(
    BuildContext context,
    Design design,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('design_card_${design.id}'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delay = index * 0.1;
        // Fix division by zero when delay >= 1.0
        final adjustedValue = delay >= 1.0
            ? value
            : ((value - delay).clamp(0.0, 1.0) / (1.0 - delay)).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * (1 - adjustedValue)),
          child: Opacity(
            opacity: adjustedValue > 0
                ? adjustedValue
                : 1.0, // Ensure visibility
            child: Transform.scale(
              scale: 0.85 + (0.15 * adjustedValue),
              child: _buildDesignCard(context, design),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesignCard(BuildContext context, Design design) {
    // Check if design has a file (PDF, image, etc.)
    final hasFile = _hasFile(design);
    // Check if file is PDF - if so, only show image and file download, not image download
    final isPdfFile = _isPdfFile(design);

    return Container(
      constraints: BoxConstraints(minHeight: 100.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: SizedBox(
                width: double.infinity,
                height: 220.h,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surfaceVariant,
                            AppColors.surfaceVariant.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: design.imageUrlString.isNotEmpty
                          ? Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: design.imageUrlString,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: AppColors.surfaceVariant,
                                    child: Center(
                                      child: isPdfFile
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(height: 12.h),
                                                Text(
                                                  'PDF',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    // For PDF files, show PDF icon
                                    if (isPdfFile) {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: AppColors.surfaceVariant,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf_rounded,
                                                color: AppColors.error,
                                                size: 64.sp,
                                              ),
                                              SizedBox(height: 8.h),
                                              Text(
                                                'PDF',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: AppColors.surfaceVariant,
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: AppColors.textSecondary,
                                          size: 40.sp,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: AppColors.surfaceVariant,
                              child: Center(
                                child: isPdfFile
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.picture_as_pdf_rounded,
                                            color: AppColors.error,
                                            size: 64.sp,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            'PDF',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Icon(
                                        Icons.image_outlined,
                                        color: AppColors.textTertiary,
                                        size: 64.sp,
                                      ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Only show image download button if file is NOT PDF
                    // For PDF files, we only show the file download button in the file section
                    if (design.imageUrlString.isNotEmpty && !isPdfFile)
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child: BlocBuilder<DesignCubit, DesignState>(
                          buildWhen: (previous, current) {
                            final prevDownloading =
                                previous is DesignDownloading &&
                                previous.designId == design.id &&
                                !previous.isFile;
                            final currDownloading =
                                current is DesignDownloading &&
                                current.designId == design.id &&
                                !current.isFile;

                            return prevDownloading != currDownloading;
                          },
                          builder: (context, state) {
                            final isDownloading =
                                state is DesignDownloading &&
                                state.designId == design.id &&
                                !state.isFile;
                            return Bounce(
                              onTap: isDownloading
                                  ? null
                                  : () {
                                      context
                                          .read<DesignCubit>()
                                          .downloadDesign(design);
                                    },
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: isDownloading
                                    ? SizedBox(
                                        width: 18.w,
                                        height: 18.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              design.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attach_money_rounded,
                                        size: 14.sp,
                                        color: AppColors.textOnPrimary,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        design.price,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textOnPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                if (design.active)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color: AppColors.success.withOpacity(
                                          0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 12.sp,
                                          color: AppColors.success,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          AppTexts.active,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // File section - Show for ALL file types: PDFs, images, videos, documents, etc.
                  // This condition checks fileUrl, file object, and fileUrlString
                  // For PDFs: show imageUrl in image section, and fileUrl in file section for download
                  if (hasFile) ...[
                    SizedBox(height: 16.h),
                    Container(
                      key: ValueKey('file_section_${design.id}'),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              _getFileIcon(_getFileMimeType(design)),
                              color: AppColors.info,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getFileName(design),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _getFileSize(design),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          BlocBuilder<DesignCubit, DesignState>(
                            buildWhen: (previous, current) {
                              final prevDownloading =
                                  previous is DesignDownloading &&
                                  previous.designId == design.id &&
                                  previous.isFile;
                              final currDownloading =
                                  current is DesignDownloading &&
                                  current.designId == design.id &&
                                  current.isFile;

                              return prevDownloading != currDownloading;
                            },
                            builder: (context, state) {
                              final isDownloading =
                                  state is DesignDownloading &&
                                  state.designId == design.id &&
                                  state.isFile;
                              return Bounce(
                                onTap: isDownloading
                                    ? null
                                    : () {
                                        context
                                            .read<DesignCubit>()
                                            .downloadFile(design);
                                      },
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: isDownloading
                                      ? SizedBox(
                                          width: 18.w,
                                          height: 18.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.download_rounded,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if design has a file (either fileUrl or file object)
  /// This method checks all possible ways a file can be present
  /// Works for all file types: PDF, images, videos, documents, etc.
  bool _hasFile(Design design) {
    // Priority 1: Check if file object exists (most reliable - works for PDFs, images, etc.)
    if (design.file != null) {
      return true;
    }
    // Priority 2: Check if fileUrl exists and is not empty
    if (design.fileUrl != null && design.fileUrl!.trim().isNotEmpty) {
      return true;
    }
    // Priority 3: Check if fileUrlString is not empty (covers both cases)
    if (design.fileUrlString.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  /// Check if the file is a PDF
  /// Returns true if file.mimeType is "application/pdf"
  bool _isPdfFile(Design design) {
    if (design.file != null && design.file!.mimeType.isNotEmpty) {
      return design.file!.mimeType.toLowerCase() == 'application/pdf';
    }
    // Check fileUrl extension as fallback
    if (design.fileUrlString.isNotEmpty) {
      final url = design.fileUrlString.toLowerCase();
      return url.endsWith('.pdf');
    }
    return false;
  }

  /// Get file mime type from design
  String _getFileMimeType(Design design) {
    if (design.file != null && design.file!.mimeType.isNotEmpty) {
      return design.file!.mimeType;
    }
    // Default to PDF if we have a file but no mimeType
    return 'application/pdf';
  }

  /// Get file name from design
  String _getFileName(Design design) {
    // First try to get name from file object
    if (design.file != null && design.file!.name.isNotEmpty) {
      return design.file!.name;
    }
    // Then try to extract from fileUrlString
    if (design.fileUrlString.isNotEmpty) {
      final fileName = design.fileUrlString.split('/').last;
      if (fileName.isNotEmpty) {
        return fileName;
      }
    }
    // Fallback
    return AppTexts.file;
  }

  String _getFileSize(Design design) {
    if (design.file != null && design.file!.size > 0) {
      return _formatFileSize(design.file!.size);
    }
    return AppTexts.unknown;
  }

  IconData _getFileIcon(String mimeType) {
    if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (mimeType.contains('image')) {
      return Icons.image_rounded;
    } else if (mimeType.contains('video')) {
      return Icons.video_file_rounded;
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description_rounded;
    } else if (mimeType.contains('excel') || mimeType.contains('sheet')) {
      return Icons.table_chart_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surfaceVariant.withOpacity(0.5),
            child: Container(
              height: 280.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
