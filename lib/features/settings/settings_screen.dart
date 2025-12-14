import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../core/di/inject.dart';
import '../../core/services/storage_service.dart';
import '../../main.dart';
import '../../shared/widgets/curved_bottom_nav_bar.dart';
import '../profile/cubit/profile_cubit.dart';
import '../profile/cubit/profile_state.dart';
import '../profile/data/models/profile_models.dart';
import '../profile/data/repositories/profile_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentBottomNavIndex = 1;
  final StorageService _storageService = sl<StorageService>();

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppTexts.logout,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          AppTexts.logoutConfirmation,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppTexts.cancel,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppTexts.logout,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Clear all auth data
      await _storageService.clearAll();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProfileCubit(ProfileRepository());
        cubit.checkAuth();
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
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return _buildLoadingState();
                  } else if (state is ProfileLoaded) {
                    return _buildProfileContent(context, state.profile);
                  } else if (state is ProfileError) {
                    // On error, show default settings
                    return _buildDefaultSettings(context);
                  }
                  return _buildDefaultSettings(context);
                },
              ),
            ),
          ),
          bottomNavigationBar: CurvedBottomNavBar(
            currentIndex: _currentBottomNavIndex,
            onTap: (index) {
              setState(() {
                _currentBottomNavIndex = index;
              });
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              } else if (index == 1) {}
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surfaceVariant.withOpacity(0.5),
            child: Container(
              height: 28.h,
              width: 150.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surfaceVariant.withOpacity(0.5),
            child: Container(
              height: 200.h,
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

  Widget _buildDefaultSettings(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.settings,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          _buildLogoutCard(),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.settings,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),

          _buildProfileNavigationCardInContent(context, profile),
          SizedBox(height: 24.h),
          _buildLanguageCard(),
          SizedBox(height: 24.h),

          // if (profile.role == 'user') ...[
          //   Text(
          //     AppTexts.myMaintenances,
          //     style: TextStyle(
          //       fontSize: 20.sp,
          //       fontWeight: FontWeight.w700,
          //       color: AppColors.textPrimary,
          //     ),
          //   ),
          //   SizedBox(height: 16.h),
          //
          //   if (profile.maintenances.isEmpty)
          //     Center(
          //       child: Padding(
          //         padding: EdgeInsets.all(32.w),
          //         child: Text(
          //           AppTexts.noMaintenancesAvailable,
          //           style: TextStyle(
          //             fontSize: 16.sp,
          //             color: AppColors.textSecondary,
          //           ),
          //         ),
          //       ),
          //     )
          //   else
          //     ...profile.maintenances.map(
          //       (maintenance) => Padding(
          //         padding: EdgeInsets.only(bottom: 12.h),
          //         child: _buildMaintenanceCard(maintenance),
          //       ),
          //     ),
          //
          //   SizedBox(height: 24.h),
          // ],
          _buildLanguageCard(),
          SizedBox(height: 24.h),
          _buildLogoutCard(),
        ],
      ),
    );
  }

  Widget _buildProfileNavigationCardInContent(
    BuildContext context,
    UserProfile profile,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.profile);
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Profile Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child:
                              profile.imageUrl != null &&
                                  profile.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: profile.imageUrl!,
                                  width: 60.w,
                                  height: 60.w,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 60.w,
                                        height: 60.w,
                                        color: AppColors.surfaceVariant,
                                        child: Icon(
                                          Icons.person,
                                          color: AppColors.textSecondary,
                                          size: 30.sp,
                                        ),
                                      ),
                                )
                              : Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                    size: 30.sp,
                                  ),
                                ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.profile,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                profile.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textTertiary,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
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
          Row(
            children: [
              if (profile.imageUrl != null && profile.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: profile.imageUrl!,
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 80.w,
                      height: 80.h,
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 40.sp,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 40.sp,
                  ),
                ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      profile.phone,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (profile.address.isNotEmpty ||
                        profile.city.isNotEmpty ||
                        profile.state.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        '${profile.address.isNotEmpty ? profile.address : ''}${profile.address.isNotEmpty && profile.city.isNotEmpty ? ', ' : ''}${profile.city.isNotEmpty ? profile.city : ''}${(profile.address.isNotEmpty || profile.city.isNotEmpty) && profile.state.isNotEmpty ? ', ' : ''}${profile.state.isNotEmpty ? profile.state : ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(Maintenance maintenance) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
          // Status Badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(maintenance.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  maintenance.status,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(maintenance.status),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Problem Details
          Text(
            maintenance.problemDetails,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),

          // Warning/Message based on assigned_by
          if (maintenance.assignedBy == 'user')
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppTexts.userAssignedWarning,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (maintenance.assignedBy == 'Admin')
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppTexts.adminAssignedMessage,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 12.h),

          // Image if available
          if (maintenance.imageUrlString.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: maintenance.imageUrlString,
                width: double.infinity,
                height: 150.h,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 150.h,
                  color: AppColors.surfaceVariant,
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

          SizedBox(height: 12.h),

          // Created Date
          Text(
            '${AppTexts.createdAt}: ${maintenance.createdAt}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildLanguageCard() {
    final localizations = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);
    final currentLanguage = appLanguageFromLocale(currentLocale);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.language,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations?.language ?? AppTexts.settings,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    localizations?.selectLanguage ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    AppLanguage language,
    String label,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        final appState = MyApp.of(context);
        if (appState != null) {
          appState.setLocale(language.locale);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: _handleLogout,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.error.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.logout, color: AppColors.error, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.logout,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      AppTexts.logoutDescription,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
