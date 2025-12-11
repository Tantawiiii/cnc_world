
import 'package:cnc_world/features/auth/register/ui/widgets/build_role_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/routing/app_routes.dart';
import '../data/models/register_models.dart';


class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.6 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      AppTexts.selectRole,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        foreground: Paint()
                          ..shader = AppColors.brandGradient.createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                          ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Text(
                      AppTexts.selectRoleSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  SizedBox(height: 60.h),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.85,
                      children: [
                        AnimatedBuilder(
                          animation: _cardAnimations[0],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + (_cardAnimations[0].value * 0.2),
                              child: Opacity(
                                opacity: _cardAnimations[0].value,
                                child: child,
                              ),
                            );
                          },
                          child: RoleCard(
                            title: AppTexts.roleUser,
                            icon: Icons.person_outline,
                            role: UserRole.user,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _cardAnimations[1],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + (_cardAnimations[1].value * 0.2),
                              child: Opacity(
                                opacity: _cardAnimations[1].value,
                                child: child,
                              ),
                            );
                          },
                          child: RoleCard(
                            title: AppTexts.roleEngineer,
                            icon: Icons.engineering_outlined,
                            role: UserRole.engineer,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _cardAnimations[2],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + (_cardAnimations[2].value * 0.2),
                              child: Opacity(
                                opacity: _cardAnimations[2].value,
                                child: child,
                              ),
                            );
                          },
                          child: RoleCard(
                            title: AppTexts.roleSeller,
                            icon: Icons.store_outlined,
                            role: UserRole.seller,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _cardAnimations[3],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + (_cardAnimations[3].value * 0.2),
                              child: Opacity(
                                opacity: _cardAnimations[3].value,
                                child: child,
                              ),
                            );
                          },
                          child: RoleCard(
                            title: AppTexts.roleMerchant,
                            icon: Icons.business_outlined,
                            role: UserRole.merchant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTexts.alreadyHaveAccount,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoutes.login),
                          child: Text(
                            AppTexts.backToLogin,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
