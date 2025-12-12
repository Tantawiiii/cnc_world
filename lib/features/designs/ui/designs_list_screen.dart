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
                            content: Text('تم تحميل الصورة بنجاح'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (state is DesignDownloadError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('فشل التحميل: ${state.message}'),
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
                            'لا توجد تصميمات متاحة',
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
        final adjustedValue = ((value - delay).clamp(0.0, 1.0) / (1.0 - delay))
            .clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * (1 - adjustedValue)),
          child: Opacity(
            opacity: adjustedValue,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: design.imageUrlString,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 200.h,
                      color: AppColors.surfaceVariant,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 200.h,
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 32.sp,
                      ),
                    ),
                  ),
                  // Download button overlay - تنزيل الصورة مباشرة من imageUrl
                  if (design.imageUrlString.isNotEmpty)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: BlocBuilder<DesignCubit, DesignState>(
                        buildWhen: (previous, current) {
                          final prevDownloading =
                              previous is DesignDownloading &&
                              previous.designId == design.id;
                          final currDownloading =
                              current is DesignDownloading &&
                              current.designId == design.id;
                          final prevDownloaded =
                              previous is DesignDownloaded &&
                              previous.designId == design.id;
                          final currDownloaded =
                              current is DesignDownloaded &&
                              current.designId == design.id;
                          final prevError =
                              previous is DesignDownloadError &&
                              previous.designId == design.id;
                          final currError =
                              current is DesignDownloadError &&
                              current.designId == design.id;

                          return prevDownloading != currDownloading ||
                              prevDownloaded != currDownloaded ||
                              prevError != currError;
                        },
                        builder: (context, state) {
                          final isDownloading =
                              state is DesignDownloading &&
                              state.designId == design.id;
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isDownloading
                                    ? null
                                    : () {
                                        context
                                            .read<DesignCubit>()
                                            .downloadDesign(design);
                                      },
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  child: isDownloading
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.download,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            design.price,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (design.active)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'نشط',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
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
    );
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
