import 'package:cnc_world/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../cubit/home_cubit.dart';
import '../../data/models/category_models.dart';
import 'category_card_widget.dart';
import 'slider_section_widget.dart';
import 'package:shimmer/shimmer.dart';

class HomeContentWidget extends StatefulWidget {
  const HomeContentWidget({super.key});

  @override
  State<HomeContentWidget> createState() => _HomeContentWidgetState();
}

class _HomeContentWidgetState extends State<HomeContentWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final StorageService _storageService = di.sl<StorageService>();
  late AnimationController _categoriesAnimationController;
  late Animation<double> _categoriesAnimation;
  bool _hasAnimated = false;
  List<CategoryItem>? _cachedCategories;
  Locale? _cachedLocale;

  @override
  bool get wantKeepAlive => true;

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

    if (!_hasAnimated) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _categoriesAnimationController.forward();
          _hasAnimated = true;
        }
      });
    } else {
      _categoriesAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _categoriesAnimationController.dispose();
    super.dispose();
  }

  String _getUserName(BuildContext context) {
    final userData = _storageService.getUserData();
    final localizations = AppLocalizations.of(context);
    return userData?['name'] ??
        (localizations?.defaultUserName ?? AppTexts.defaultUserName);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final topThirdHeight = screenHeight / 3;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topThirdHeight,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: CustomPaint(painter: _TopBackgroundPainter()),
          ),
        ),
        // Content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 28.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.of(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.welcome ?? AppTexts.welcome,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getUserName(context),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppAssets.appLogoImg,
                        height: 60.h,
                        width: 60.w,
                      ),
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
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: AppColors.error,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Builder(
                                  builder: (context) {
                                    final localizations = AppLocalizations.of(
                                      context,
                                    );
                                    return Text(
                                      '${localizations?.errorLoadingSliders ?? AppTexts.errorLoadingSliders}: ${state.message}',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                            );
                          }

                          return _buildSliderShimmer();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
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
      ],
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

  List<CategoryItem> _getCategories(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    if (_cachedCategories == null || _cachedLocale != currentLocale) {
      final localizations = AppLocalizations.of(context);
      _cachedCategories = [
        CategoryItem(
          title:
              localizations?.homeCategoryMaintenance ??
              AppTexts.homeCategoryMaintenance,
          icon: AppAssets.cncMagnificent,
          color: AppColors.border,
          route: AppRoutes.maintenance,
        ),
        CategoryItem(
          title:
              localizations?.homeCategoryUsedMachines ??
              AppTexts.homeCategoryUsedMachines,
          icon: AppAssets.cncUsedMachines,
          color: AppColors.border,
          route: AppRoutes.usedMachines,
        ),
        CategoryItem(
          title:
              localizations?.homeCategoryManufacturingSupplies ??
              AppTexts.homeCategoryManufacturingSupplies,
          icon: AppAssets.cncManufacturingSupplies,
          color: AppColors.border,
          route: AppRoutes.merchants,
        ),
        CategoryItem(
          title:
              localizations?.homeCategoryCompanyDirectory ??
              AppTexts.homeCategoryCompanyDirectory,
          icon: AppAssets.cncGuide,
          color: AppColors.border,
          route: AppRoutes.companies,
        ),
        CategoryItem(
          title:
              localizations?.homeCategoryDesigns ??
              AppTexts.homeCategoryDesigns,
          icon: AppAssets.cncDesignd,
          color: AppColors.border,
          route: AppRoutes.designs,
        ),
        CategoryItem(
          title:
              localizations?.homeCategoryWorkshopDirectory ??
              AppTexts.homeCategoryWorkshopDirectory,
          icon: AppAssets.cncmachen,
          color: AppColors.border,
          route: AppRoutes.sellers,
        ),
      ];
      _cachedLocale = currentLocale;
    }

    return _cachedCategories!;
  }

  Widget _buildCategoriesGrid() {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          final categories = _getCategories(context);

          return AnimatedBuilder(
            animation: _categoriesAnimation,
            builder: (context, child) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.75,
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
        },
      ),
    );
  }

  Widget _buildAnimatedCategoryCard(
    CategoryItem category,
    int index,
    int totalItems,
    double animationValue,
  ) {
    final delay = (index / totalItems) * 0.4;
    final adjustedValue = ((animationValue - delay) / (1.0 - delay)).clamp(
      0.0,
      1.0,
    );

    final opacity = Curves.easeOut.transform(adjustedValue);
    final slideOffset =
        (1.0 - Curves.easeOutCubic.transform(adjustedValue)) * 40.h;
    final scale = 0.7 + (Curves.elasticOut.transform(adjustedValue) * 0.3);
    final rotation = (1.0 - Curves.easeOut.transform(adjustedValue)) * 0.1;

    return Transform.translate(
      offset: Offset(0, slideOffset),
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: opacity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: RepaintBoundary(
                child: CategoryCardWidget(
                  category: category,
                  onTap: () {
                    Navigator.of(context).pushNamed(category.route);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.08),
          AppColors.primary.withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw curved path
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.8,
        size.width * 0.3,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.9,
        0,
        size.height * 0.7,
      )
      ..close();

    canvas.drawPath(path, paint);

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primary.withValues(alpha: 0.05);

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.15,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.width * 0.1,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
