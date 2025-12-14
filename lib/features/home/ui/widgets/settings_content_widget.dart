import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../main.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../profile/cubit/profile_cubit.dart';
import '../../../profile/cubit/profile_state.dart';
import '../../../profile/data/models/profile_models.dart';

class SettingsContentWidget extends StatelessWidget {
  const SettingsContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = di.sl<StorageService>();
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return _buildLoadingState();
        } else if (state is ProfileLoaded) {
          return _buildProfileContent(context, state.profile, storageService);
        } else if (state is ProfileError) {
          return _buildDefaultSettings(context, storageService);
        }
        return _buildDefaultSettings(context, storageService);
      },
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

  Widget _buildDefaultSettings(
    BuildContext context,
    StorageService storageService,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              return Text(
                localizations?.settings ?? AppTexts.settings,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          _buildLanguageCard(context),
          SizedBox(height: 24.h),
          _buildLogoutCard(context, storageService),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserProfile profile,
    StorageService storageService,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              return Text(
                localizations?.settings ?? AppTexts.settings,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          _buildProfileNavigationCard(context, profile),
          SizedBox(height: 24.h),
          _buildLanguageCard(context),
          SizedBox(height: 24.h),
          _buildLogoutCard(context, storageService),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildLanguageOption(
                    context,
                    AppLanguage.ar,
                    localizations?.arabic ?? 'العربية',
                    currentLanguage == AppLanguage.ar,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildLanguageOption(
                    context,
                    AppLanguage.en,
                    localizations?.english ?? 'English',
                    currentLanguage == AppLanguage.en,
                  ),
                ),
              ],
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

  Widget _buildProfileNavigationCard(
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
                              Builder(
                                builder: (context) {
                                  final localizations = AppLocalizations.of(
                                    context,
                                  );
                                  return Text(
                                    localizations?.profile ?? AppTexts.profile,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  );
                                },
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

  Widget _buildLogoutCard(BuildContext context, StorageService storageService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: () => _handleLogout(context, storageService),
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
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.of(context);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations?.logout ?? AppTexts.logout,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              localizations?.logoutDescription ??
                                  AppTexts.logoutDescription,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
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

  Future<void> _handleLogout(
    BuildContext context,
    StorageService storageService,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(
            localizations?.logout ?? AppTexts.logout,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            localizations?.logoutConfirmation ?? AppTexts.logoutConfirmation,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                localizations?.cancel ?? AppTexts.cancel,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                localizations?.logout ?? AppTexts.logout,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await storageService.clearAll();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }
}
