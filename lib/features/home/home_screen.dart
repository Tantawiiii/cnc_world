import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import '../../core/routing/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/curved_bottom_nav_bar.dart';
import 'cubit/home_cubit.dart';
import 'data/models/category_models.dart';
import 'ui/widgets/category_card_widget.dart';
import 'ui/widgets/slider_section_widget.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = di.sl<StorageService>();
  int _currentBottomNavIndex = 0;
  late AnimationController _categoriesAnimationController;
  late Animation<double> _categoriesAnimation;

  @override
  void initState() {
    super.initState();
    _categoriesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _categoriesAnimation = CurvedAnimation(
      parent: _categoriesAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _categoriesAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _categoriesAnimationController.dispose();
    super.dispose();
  }

  String _getUserName() {
    final userData = _storageService.getUserData();
    return userData?['name'] ?? 'المستخدم';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => HomeCubit()..loadSliders(),
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      Text(
                        AppTexts.welcome,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getUserName(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final homeCubit = context.read<HomeCubit>();
                      await homeCubit.loadSliders();
                    },
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              if (state is HomeLoading) {
                                return _buildSliderShimmer();
                              } else if (state is HomeSlidersLoaded) {
                                if (state.sliders.isNotEmpty) {
                                  return SliderSectionWidget(
                                    sliders: state.sliders,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              } else if (state is HomeError) {
                                print('Error: ${state.message}');
                                return Container(
                                  height: 200.h,
                                  padding: EdgeInsets.all(16.w),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      20.r,
                                    ),
                                    border: Border.all(
                                      color: AppColors.error,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Error Sliders: ${state.message}',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }

                              return _buildSliderShimmer();
                            },
                          ),

                          SizedBox(height: 24.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: _buildCategoriesGrid(),
                          ),

                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          } else if (index == 1) {
            Navigator.of(context).pushNamed(AppRoutes.settings);
          }
        },
      ),
    );
  }

  Widget _buildSliderShimmer() {
    return Column(
      children: [
        SizedBox(height: 14.h),
        Container(
          height: 200.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 8.h,
              width: 8.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      CategoryItem(
        title: AppTexts.homeCategoryMaintenance,
        icon: Icons.build_outlined,
        color: AppColors.primaryGradient,
      ),
      CategoryItem(
        title: AppTexts.homeCategoryUsedMachines,
        icon: Icons.precision_manufacturing_outlined,
        color: AppColors.secondaryGradient,
      ),
      CategoryItem(
        title: AppTexts.homeCategoryManufacturingSupplies,
        icon: Icons.inventory_2_outlined,
        color: AppColors.accentGradient,
      ),
      CategoryItem(
        title: AppTexts.homeCategoryCompanyDirectory,
        icon: Icons.business_outlined,
        color: AppColors.brandGradient,
      ),
      CategoryItem(
        title: AppTexts.homeCategoryDesigns,
        icon: Icons.design_services_outlined,
        color: AppColors.primaryGradient,
      ),
      CategoryItem(
        title: AppTexts.homeCategoryWorkshopDirectory,
        icon: Icons.factory_outlined,
        color: AppColors.secondaryGradient,
      ),
    ];

    return AnimatedBuilder(
      animation: _categoriesAnimation,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildAnimatedCategoryCard(
              categories[index],
              index,
              categories.length,
              _categoriesAnimation.value,
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedCategoryCard(
    CategoryItem category,
    int index,
    int totalItems,
    double animationValue,
  ) {
    // Staggered animation: each card starts at a different time
    final delay = (index / totalItems) * 0.5; // Stagger delay (0 to 0.5)
    final adjustedValue = ((animationValue - delay) / (1.0 - delay)).clamp(
      0.0,
      1.0,
    );

    // Fade animation
    final opacity = Curves.easeOut.transform(adjustedValue);

    // Slide animation (from bottom)
    final slideOffset =
        (1.0 - Curves.easeOutCubic.transform(adjustedValue)) * 30.h;

    // Scale animation
    final scale = 0.8 + (Curves.elasticOut.transform(adjustedValue) * 0.2);

    return Transform.translate(
      offset: Offset(0, slideOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: CategoryCardWidget(
            category: category,
            onTap: () {
              // Handle category tap
            },
          ),
        ),
      ),
    );
  }
}
