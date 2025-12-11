import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constant/app_colors.dart';
import '../../data/models/slider_models.dart';

class SliderSectionWidget extends StatefulWidget {
  final List<SliderItem> sliders;

  const SliderSectionWidget({super.key, required this.sliders});

  @override
  State<SliderSectionWidget> createState() => _SliderSectionWidgetState();
}

class _SliderSectionWidgetState extends State<SliderSectionWidget> {
  final PageController _sliderController = PageController();
  int _currentSliderIndex = 0;

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  String _getSliderImageUrl(SliderItem slider) {
    if (slider.imageUrl != null && slider.imageUrl!.isNotEmpty) {
      return slider.imageUrl!;
    }
    if (slider.image?.fullUrl != null && slider.image!.fullUrl.isNotEmpty) {
      return slider.image!.fullUrl;
    }
    return '';
  }

  Widget _buildSliderIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: isActive ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 14.h),
        SizedBox(
          height: 200.h,
          child: PageView.builder(
            controller: _sliderController,
            onPageChanged: (index) {
              setState(() {
                _currentSliderIndex = index;
              });
            },
            itemCount: widget.sliders.length,
            itemBuilder: (context, index) {
              final slider = widget.sliders[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _getSliderImageUrl(slider),
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            _buildShimmerPlaceholder(),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                            size: 48.sp,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                      if (slider.text != null || slider.description != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (slider.text != null)
                                  Text(
                                    slider.text!,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (slider.description != null) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    slider.description!,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.sliders.length,
            (index) => _buildSliderIndicator(index == _currentSliderIndex),
          ),
        ),
      ],
    );
  }
}
