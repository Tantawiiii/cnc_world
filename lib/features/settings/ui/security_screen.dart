import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  static const List<String> _bullets = [
    AppTexts.securityBullet1,
    AppTexts.securityBullet2,
    AppTexts.securityBullet3,
    AppTexts.securityBullet4,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.securityPolicy),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.yourDataProtection,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ..._bullets.map(
                    (bullet) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        '• $bullet',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppTexts.securitySuspiciousActivityMessage,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
