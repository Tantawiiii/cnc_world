import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/merchant_cubit.dart';
import '../cubit/merchant_state.dart';
import '../data/models/merchant_models.dart';

class MerchantsListScreen extends StatefulWidget {
  const MerchantsListScreen({super.key});

  @override
  State<MerchantsListScreen> createState() => _MerchantsListScreenState();
}

class _MerchantsListScreenState extends State<MerchantsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_searchQuery.isNotEmpty) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8) {
      final cubit = context.read<MerchantCubit>();
      final currentState = cubit.state;

      if (currentState is MerchantsLoaded &&
          currentState.hasMore &&
          !_isLoadingMore &&
          currentState is! MerchantsLoadingMore) {
        _isLoadingMore = true;
        cubit
            .loadMoreMerchants()
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
                          AppTexts.homeCategoryManufacturingSupplies,
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '${AppTexts.homeCategoryManufacturingSupplies}...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                Expanded(
                  child: BlocBuilder<MerchantCubit, MerchantState>(
                    builder: (context, state) {
                      if (state is MerchantsLoading &&
                          state is! MerchantsLoadingMore) {
                        return _buildShimmerList();
                      }

                      List<Merchant> merchants = [];
                      bool hasMore = false;
                      int? currentPage;
                      int? lastPage;
                      int? totalItems;

                      if (state is MerchantsLoaded) {
                        merchants = state.merchants;
                        hasMore = state.hasMore;
                        currentPage = state.meta?.currentPage;
                        lastPage = state.meta?.lastPage;
                        totalItems = state.meta?.total;
                      }

                      final filteredMerchants = merchants.where((merchant) {
                        if (_searchQuery.isEmpty) return true;
                        return merchant.name.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                merchant.phone.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                (merchant.whatsappNumber ?? '').toLowerCase().contains(
                                  _searchQuery,
                                );
                      }).toList();

                      if (filteredMerchants.isEmpty &&
                          state is! MerchantsLoading &&
                          state is! MerchantsLoadingMore) {
                        return Center(
                          child: Text(
                            AppTexts.noMerchantsAvailable,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      if (state is MerchantsError) {
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
                                  context.read<MerchantCubit>().loadMerchants();
                                },
                                child: Text(AppTexts.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (merchants.isNotEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<MerchantCubit>().loadMerchants();
                          },
                          color: AppColors.primary,
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            itemCount: filteredMerchants.length +
                                ((_searchQuery.isEmpty && hasMore) ? 1 : 0) +
                                ((_searchQuery.isEmpty &&
                                        currentPage != null &&
                                        lastPage != null)
                                    ? 1
                                    : 0),
                            separatorBuilder: (context, index) {
                              if (index >= filteredMerchants.length) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(height: 12.h);
                            },
                            itemBuilder: (context, index) {
                              if (_searchQuery.isEmpty &&
                                  hasMore &&
                                  index == filteredMerchants.length) {
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

                              final footerIndex = filteredMerchants.length +
                                  ((_searchQuery.isEmpty && hasMore) ? 1 : 0);
                              if (_searchQuery.isEmpty &&
                                  currentPage != null &&
                                  lastPage != null &&
                                  index == footerIndex) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                                  child: Center(
                                    child: Text(
                                      'Page $currentPage / $lastPage'
                                      '${totalItems != null ? '  •  Total: $totalItems' : ''}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return _buildAnimatedMerchantCard(
                                context,
                                filteredMerchants[index],
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

  Widget _buildAnimatedMerchantCard(
    BuildContext context,
    Merchant merchant,
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
              child: _buildMerchantCard(context, merchant),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMerchantCard(BuildContext context, Merchant merchant) {
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
            ).pushNamed(AppRoutes.merchantDetail, arguments: merchant.id);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: merchant.imageUrlString,
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
                        merchant.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14.sp,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${merchant.rating.toStringAsFixed(1)} (${merchant.totalReviews} ${AppTexts.reviews})',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
                              merchant.phone,
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
                      if (merchant.whatsappNumber != null &&
                          merchant.whatsappNumber!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.chat,
                              size: 14.sp,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                merchant.whatsappNumber!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.success,
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
