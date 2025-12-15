import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/seller_cubit.dart';
import '../cubit/seller_state.dart';
import '../data/models/seller_models.dart';
import '../data/repositories/seller_repository.dart';

class SellersListScreen extends StatefulWidget {
  const SellersListScreen({super.key});

  @override
  State<SellersListScreen> createState() => _SellersListScreenState();
}

class _SellersListScreenState extends State<SellersListScreen> {
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

    if (currentScroll >= maxScroll * 0.8) {
      final cubit = context.read<SellerCubit>();
      final currentState = cubit.state;

      if (currentState is SellersLoaded &&
          currentState.hasMore &&
          !_isLoadingMore &&
          currentState is! SellersLoadingMore) {
        _isLoadingMore = true;
        cubit
            .loadMoreSellers()
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
                          AppTexts.homeCategoryWorkshopDirectory,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: BlocBuilder<SellerCubit, SellerState>(
                    builder: (context, state) {
                      if (state is SellersLoading &&
                          state is! SellersLoadingMore) {
                        return _buildShimmerList();
                      }

                      List<Seller> sellers = [];
                      bool hasMore = false;

                      if (state is SellersLoaded) {
                        sellers = state.sellers;
                        hasMore = state.hasMore;
                      }

                      if (sellers.isEmpty &&
                          state is! SellersLoading &&
                          state is! SellersLoadingMore) {
                        return Center(
                          child: Text(
                            AppTexts.noSellersAvailable,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      if (state is SellersError) {
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
                                  context.read<SellerCubit>().loadSellers();
                                },
                                child: Text(AppTexts.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (sellers.isNotEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<SellerCubit>().loadSellers();
                          },
                          color: AppColors.primary,
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            itemCount: sellers.length + (hasMore ? 1 : 0),
                            separatorBuilder: (context, index) {
                              if (index >= sellers.length) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(height: 12.h);
                            },
                            itemBuilder: (context, index) {
                              if (index >= sellers.length) {
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
                              return _buildAnimatedSellerCard(
                                context,
                                sellers[index],
                                index,
                              );
                            },
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

  Widget _buildAnimatedSellerCard(
    BuildContext context,
    Seller seller,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
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
            opacity: adjustedValue > 0 ? adjustedValue : 1.0,
            child: Transform.scale(
              scale: 0.85 + (0.15 * adjustedValue),
              child: _buildSellerCard(context, seller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSellerCard(BuildContext context, Seller seller) {
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
        child: InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.sellerDetail, arguments: seller.id);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: seller.imageUrlString,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100.w,
                      height: 100.h,
                      color: AppColors.surfaceVariant,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100.w,
                      height: 100.h,
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.workshopName.isNotEmpty
                            ? seller.workshopName
                            : seller.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      if (seller.natureOfWork.isNotEmpty)
                        Text(
                          seller.natureOfWork,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              seller.phone,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (seller.fullAddress.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                seller.fullAddress,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
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
              height: 100.h,
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
