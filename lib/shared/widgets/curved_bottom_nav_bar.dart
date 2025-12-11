import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';

class CurvedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CurvedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomNavBarClipper(),
      child: Container(
        height: 75.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.borderLight, AppColors.borderLight],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: AppTexts.home,
              index: 0,
              isActive: currentIndex == 0,
            ),
            SizedBox(width: 80.w), // Space for notch
            _buildNavItem(
              icon: Icons.settings_rounded,
              label: AppTexts.settings,
              index: 1,
              isActive: currentIndex == 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isActive ? AppColors.textOnPrimary : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textOnPrimary.withValues(alpha: 0.7),
                size: 24.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.textOnPrimary
                    : AppColors.textOnPrimary.withValues(alpha: 0.7),
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchSize = 60.w;
    final notchRadius = 25.r;
    final curveHeight = 20.h;

    // Start from left bottom
    path.moveTo(0, size.height);

    // Line to start of left curve
    path.lineTo((size.width - notchSize) / 2 - notchRadius, size.height);

    // Left curve up
    path.quadraticBezierTo(
      (size.width - notchSize) / 2 - notchRadius,
      size.height - curveHeight,
      (size.width - notchSize) / 2,
      size.height - curveHeight,
    );

    // Create notch (curved cutout)
    final notchCenterX = size.width / 2;
    final notchTopY = size.height - curveHeight - notchSize / 2;

    // Left side of notch
    path.quadraticBezierTo(
      notchCenterX - notchSize / 2 + notchRadius,
      size.height - curveHeight,
      notchCenterX - notchSize / 2 + notchRadius,
      notchTopY - notchRadius,
    );

    // Top curve of notch
    path.arcToPoint(
      Offset(
        notchCenterX + notchSize / 2 - notchRadius,
        notchTopY - notchRadius,
      ),
      radius: Radius.circular(notchRadius),
      clockwise: false,
      largeArc: false,
    );

    // Right side of notch
    path.quadraticBezierTo(
      notchCenterX + notchSize / 2 - notchRadius,
      size.height - curveHeight,
      (size.width + notchSize) / 2,
      size.height - curveHeight,
    );

    // Right curve down
    path.quadraticBezierTo(
      (size.width + notchSize) / 2 + notchRadius,
      size.height - curveHeight,
      (size.width + notchSize) / 2 + notchRadius,
      size.height,
    );

    // Line to right bottom
    path.lineTo(size.width, size.height);

    // Line to right top
    path.lineTo(size.width, 0);

    // Line to left top
    path.lineTo(0, 0);

    // Close path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
