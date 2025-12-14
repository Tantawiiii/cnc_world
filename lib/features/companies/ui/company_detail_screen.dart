import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';
import '../data/models/company_models.dart';
import '../data/repositories/company_repository.dart';

class CompanyDetailScreen extends StatelessWidget {
  final int companyId;

  const CompanyDetailScreen({super.key, required this.companyId});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CompanyCubit(CompanyRepository());
        cubit.loadCompanyDetail(companyId);
        return cubit;
      },
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
              child: BlocBuilder<CompanyCubit, CompanyState>(
                builder: (context, state) {
                  if (state is CompanyDetailLoading) {
                    return _buildLoadingState(context);
                  } else if (state is CompanyDetailLoaded) {
                    return _buildDetailContent(context, state.company);
                  } else if (state is CompanyDetailError) {
                    return _buildErrorState(context, state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
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
                  child: Shimmer.fromColors(
                    baseColor: AppColors.surfaceVariant,
                    highlightColor: AppColors.surfaceVariant.withOpacity(0.5),
                    child: Container(
                      height: 20.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Image shimmer
          Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surfaceVariant.withOpacity(0.5),
            child: Container(
              height: 300.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: TextStyle(fontSize: 16.sp, color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<CompanyCubit>().loadCompanyDetail(companyId);
                  },
                  child: Text(AppTexts.retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailContent(BuildContext context, Company company) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                            company.companyName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (company.imageUrlString.isNotEmpty)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, imageValue, child) {
                        return Transform.translate(
                          offset: Offset(0, 40 * (1 - imageValue)),
                          child: Transform.scale(
                            scale: 0.9 + (0.1 * imageValue),
                            child: Opacity(
                              opacity: imageValue,
                              child: Container(
                                width: double.infinity,
                                height: 300.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowMedium,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: CachedNetworkImage(
                                    imageUrl: company.imageUrlString,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.surfaceVariant,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: AppColors.surfaceVariant,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: AppColors.textSecondary,
                                            size: 48.sp,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  SizedBox(height: 24.h),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, cardValue, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - cardValue)),
                        child: Opacity(
                          opacity: cardValue,
                          child: Transform.scale(
                            scale: 0.95 + (0.05 * cardValue),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              padding: EdgeInsets.all(20.w),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company.companyName,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 20.h),

                                  // Company Description
                                  if (company
                                      .companyDescription
                                      .isNotEmpty) ...[
                                    Text(
                                      AppTexts.companyDescription,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      company.companyDescription,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                  ],

                                  // Divider
                                  Divider(color: AppColors.border),
                                  SizedBox(height: 20.h),

                                  // Contact Info
                                  Text(
                                    AppTexts.contactInfo,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),

                                  // Phone
                                  InkWell(
                                    onTap: () => _makePhoneCall(company.phone),
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.phone,
                                              color: AppColors.primary,
                                              size: 20.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppTexts.phoneNumber,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  company.phone,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16.sp,
                                            color: AppColors.textTertiary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Address
                                  if (company.companyAddress.isNotEmpty) ...[
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: AppColors.info.withOpacity(
                                                0.2,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.location_on,
                                              color: AppColors.info,
                                              size: 20.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppTexts.companyAddress,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  company.companyAddress,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Products Section
                                  if (company.products.isNotEmpty) ...[
                                    SizedBox(height: 20.h),
                                    Divider(color: AppColors.border),
                                    SizedBox(height: 20.h),
                                    Text(
                                      AppTexts.products,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: company.products.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 16.h,
                                          ),
                                          child: _buildProductCard(
                                            company.products[index],
                                          ),
                                        );
                                      },
                                    ),
                                  ],

                                  SizedBox(height: 20.h),

                                  // Divider
                                  Divider(color: AppColors.border),
                                  SizedBox(height: 20.h),

                                  // Created Date
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '${AppTexts.createdAt}: ${company.createdAt}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(CompanyProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageUrlString.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: CachedNetworkImage(
                imageUrl: product.imageUrlString,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
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
                  height: 200.h,
                  color: AppColors.surfaceVariant,
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.textSecondary,
                    size: 32.sp,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),


                Text(
                  AppTexts.companyDescription,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

}
