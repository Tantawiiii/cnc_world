import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/design_cubit.dart';
import '../cubit/design_state.dart';
import '../data/models/design_models.dart';

class DesignsListScreen extends StatefulWidget {
  const DesignsListScreen({super.key});

  @override
  State<DesignsListScreen> createState() => _DesignsListScreenState();
}

class _DesignsListScreenState extends State<DesignsListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load more when user scrolls to 80% of the list
    if (currentScroll >= maxScroll * 0.8) {
      final cubit = context.read<DesignCubit>();
      final currentState = cubit.state;

      if (currentState is DesignsLoaded &&
          currentState.hasMore &&
          !_isLoadingMore &&
          currentState is! DesignsLoadingMore) {
        _isLoadingMore = true;
        cubit
            .loadMoreDesigns()
            .then((_) {
              if (mounted) {
                _isLoadingMore = false;
              }
            })
            .catchError((_) {
              if (mounted) {
                _isLoadingMore = false;
              }
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final textDirection = locale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
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
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.addDesign);
                          // Refresh designs list if design was added successfully
                          if (result == true && mounted) {
                            context.read<DesignCubit>().loadDesigns();
                          }
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
                      if (state is DesignsLoading &&
                          state is! DesignsLoadingMore) {
                        return _buildShimmerList();
                      }

                      List<Design> designs = [];
                      bool hasMore = false;

                      // All download states extend DesignsLoaded, so they all have designs, meta, links, hasMore
                      if (state is DesignsLoaded) {
                        designs = state.designs;
                        hasMore = state.hasMore;
                      }

                      if (designs.isEmpty &&
                          state is! DesignsLoading &&
                          state is! DesignsLoadingMore) {
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
                            controller: _scrollController,
                            key: ValueKey('designs_list_${designs.length}'),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            itemCount: designs.length + (hasMore ? 1 : 0),
                            separatorBuilder: (context, index) {
                              if (index >= designs.length) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(height: 12.h);
                            },
                            itemBuilder: (context, index) {
                              if (index >= designs.length) {
                                // Loading more indicator
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              }
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
    final imageUrl = _getDisplayImageUrl(design);
    final hasImage = imageUrl.isNotEmpty;

    final fileIsImage = _isImageUrl(design.fileUrlString);
    final hasFile = _hasFile(
      design,
      ignoreIfImage: fileIsImage && imageUrl == design.fileUrlString,
    );

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
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: SizedBox(
                  width: double.infinity,
                  height: 220.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 300),
                        fadeOutDuration: const Duration(milliseconds: 100),
                        placeholderFadeInDuration: const Duration(
                          milliseconds: 200,
                        ),
                        placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.surfaceVariant,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.surfaceVariant,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_rounded,
                                  color: AppColors.textSecondary,
                                  size: 48.sp,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
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
                      // View image button
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child: Bounce(
                          onTap: () => _showImageViewer(context, imageUrl),
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.visibility_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                      // Download image button - يمكن تحميل أي صورة
                      Positioned(
                        top: 12.h,
                        left: 60.w,
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

                  // File section - أي ملف يظهر في الأسفل كـ section منفصلة
                  if (hasFile) ...[
                    SizedBox(height: 16.h),
                    Container(
                      key: ValueKey('file_section_${design.id}'),
                      padding: EdgeInsets.all(14.w),
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
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              _getFileIcon(_getFileMimeType(design)),
                              color: AppColors.info,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getFileName(design),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _getFileSize(design),
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
                          SizedBox(width: 8.w),
                          // View file button
                          Bounce(
                            onTap: () =>
                                _openFile(context, design.fileUrlString),
                            child: Container(
                              padding: EdgeInsets.all(11.w),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.visibility_rounded,
                                color: AppColors.info,
                                size: 22.sp,
                              ),
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

  bool _hasFile(Design design, {bool ignoreIfImage = false}) {
    if (ignoreIfImage) return false;

    if (design.file != null) return true;
    if (design.fileUrl != null && design.fileUrl!.trim().isNotEmpty) {
      return true;
    }
    if (design.fileUrlString.trim().isNotEmpty) return true;
    return false;
  }

  String _getDisplayImageUrl(Design design) {
    final imageUrl = design.imageUrlString;
    if (_isImageUrl(imageUrl)) {
      return imageUrl;
    }

    final fileUrl = design.fileUrlString;
    if (_isImageUrl(fileUrl)) {
      return fileUrl;
    }

    return '';
  }

  // يتحقق من امتداد رابط الصورة
  bool _isImageUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  String _getFileMimeType(Design design) {
    if (design.file != null && design.file!.mimeType.isNotEmpty) {
      return design.file!.mimeType;
    }

    return 'application/pdf';
  }

  String _getFileName(Design design) {
    if (design.file != null && design.file!.name.isNotEmpty) {
      return design.file!.name;
    }

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

  void _showImageViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48.sp,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 16.w,
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFile(BuildContext context, String fileUrl) async {
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File URL is not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open file'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
