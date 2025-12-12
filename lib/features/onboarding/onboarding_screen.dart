import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: AppTexts.onboardingPage1Title,
      description: AppTexts.onboardingPage1Description,
      lottieAsset: 'assets/lottie/cnc_machine.json',
      gradient: AppColors.primaryGradient,
    ),
    OnboardingPageData(
      title: AppTexts.onboardingPage2Title,
      description: AppTexts.onboardingPage2Description,
      lottieAsset: 'assets/lottie/services.json',
      gradient: AppColors.secondaryGradient,
    ),
    OnboardingPageData(
      title: AppTexts.onboardingPage3Title,
      description: AppTexts.onboardingPage3Description,
      lottieAsset: 'assets/lottie/start_journey.json',
      gradient: AppColors.brandGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _fadeController.reset();
    _scaleController.reset();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Bounce(
                      onTap: _navigateToLogin,
                      duration: const Duration(milliseconds: 80),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          AppTexts.skip,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return RepaintBoundary(
                        child: _buildPage(_pages[index], index),
                      );
                    },
                  ),
                ),

                _buildPageIndicators(),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Padding(
                    key: ValueKey(_currentPage),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        PrimaryButton(
                          title: _currentPage == _pages.length - 1
                              ? AppTexts.startNow
                              : AppTexts.next,
                          onPressed: _nextPage,
                        ),
                        SizedBox(height: 12.h),
                        if (_currentPage > 0)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Bounce(
                              onTap: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                );
                              },
                              child: Text(
                                AppTexts.previous,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData pageData, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                height: 300.h,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: pageData.gradient.colors.first.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: pageData.gradient.colors.last.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: pageData.gradient.colors
                                .map((c) => c.withOpacity(0.1))
                                .toList(),
                          ),
                        ),
                      ),
                      Center(
                        child: RepaintBoundary(
                          child: Lottie.asset(
                            pageData.lottieAsset,
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: true,
                            frameRate: FrameRate(30),
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: pageData.gradient,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(40.w),
                                child: Icon(
                                  _getIconForPage(index),
                                  size: 120.sp,
                                  color: AppColors.textOnPrimary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                pageData.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                pageData.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) => _buildIndicator(index),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: isActive ? 10.h : 8.h,
      width: isActive ? 32.w : 8.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: isActive ? _pages[_currentPage].gradient : null,
        color: isActive ? null : AppColors.border.withOpacity(0.5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _pages[_currentPage].gradient.colors.first.withOpacity(
                    0.4,
                  ),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.precision_manufacturing;
      case 1:
        return Icons.construction;
      case 2:
        return Icons.rocket_launch;
      default:
        return Icons.info;
    }
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String lottieAsset;
  final LinearGradient gradient;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.gradient,
  });
}
