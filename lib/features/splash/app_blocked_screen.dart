import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../core/constant/app_colors.dart';
import '../../core/di/inject.dart' as di;
import '../../core/services/remote_config_service.dart';

class AppBlockedScreen extends StatelessWidget {
  const AppBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 260.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.12),
                            AppColors.primary.withOpacity(0.04),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32.r),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0.0, -0.4),
                                    radius: 1.2,
                                    colors: [
                                      AppColors.primary.withOpacity(0.18),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Lottie.asset(
                                'assets/lottie/app_blocked.json',
                                fit: BoxFit.contain,
                                repeat: true,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.lock_outline_rounded,
                                    size: 110.sp,
                                    color: AppColors.primary,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: 1,
                    child: Column(
                      children: [
                        Text(
                          'التطبيق غير متاح مؤقتًا',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          di.sl<RemoteConfigService>().getMaintenanceMessage(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 40, end: 0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: child,
                      );
                    },
                    child: Opacity(
                      opacity: 1,
                      child: Text(
                        'شكرًا لتفهمك وصبرك 💛',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

