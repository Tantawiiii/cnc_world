import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/localization/app_localizations.dart';
import '../cubit/used_machine_cubit.dart';
import '../cubit/used_machine_state.dart';
import '../data/models/used_machine_models.dart';
import '../data/repositories/used_machine_repository.dart';

class UsedMachineDetailScreen extends StatelessWidget {
  final int machineId;

  const UsedMachineDetailScreen({super.key, required this.machineId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = UsedMachineCubit(UsedMachineRepository());
        cubit.loadUsedMachineDetail(machineId);
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
              child: BlocBuilder<UsedMachineCubit, UsedMachineState>(
                builder: (context, state) {
                  if (state is UsedMachineDetailLoading) {
                    return _buildLoadingState(context);
                  } else if (state is UsedMachineDetailLoaded) {
                    return _buildDetailContent(context, state.machine);
                  } else if (state is UsedMachineDetailError) {
                    return _buildErrorState(context, state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: AppColors.surfaceVariant,
                    highlightColor: AppColors.surfaceVariant.withOpacity(0.5),
                    child: Container(
                      height: 20.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Image shimmer
          Shimmer.fromColors(
            baseColor: AppColors.surfaceVariant,
            highlightColor: AppColors.surfaceVariant.withOpacity(0.5),
            child: Container(
              height: 300.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
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

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: TextStyle(fontSize: 16.sp, color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<UsedMachineCubit>().loadUsedMachineDetail(
                      machineId,
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.of(context);
                      return Text(localizations?.retry ?? AppTexts.retry);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailContent(BuildContext context, UsedMachine machine) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            machine.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Image or Video
                  if (machine.imageUrlString.isNotEmpty)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, imageValue, child) {
                        return Transform.translate(
                          offset: Offset(0, 40 * (1 - imageValue)),
                          child: Transform.scale(
                            scale: 0.9 + (0.1 * imageValue),
                            child: Opacity(
                              opacity: imageValue,
                              child: Container(
                                width: double.infinity,
                                height: 300.h,
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowMedium,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: _isVideoUrl(machine)
                                      ? _VideoPlayerWidget(
                                          videoUrl: machine.imageUrlString,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: machine.imageUrlString,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: AppColors.surfaceVariant,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: AppColors.surfaceVariant,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color:
                                                      AppColors.textSecondary,
                                                  size: 48.sp,
                                                ),
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  SizedBox(height: 24.h),

                  // Details Card
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, cardValue, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - cardValue)),
                        child: Opacity(
                          opacity: cardValue,
                          child: Transform.scale(
                            scale: 0.95 + (0.05 * cardValue),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                                  // Price
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 24.sp,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        machine.price,
                                        style: TextStyle(
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),

                                  // Description
                                  Builder(
                                    builder: (context) {
                                      final localizations = AppLocalizations.of(
                                        context,
                                      );
                                      return Text(
                                        localizations?.machineDescription ??
                                            AppTexts.machineDescription,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    machine.description,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 20.h),

                                  // Divider
                                  Divider(color: AppColors.border),
                                  SizedBox(height: 20.h),

                                  // User Info
                                  if (machine.user != null) ...[
                                    Builder(
                                      builder: (context) {
                                        final localizations =
                                            AppLocalizations.of(context);
                                        return Text(
                                          localizations?.sellerInfo ??
                                              AppTexts.sellerInfo,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        if (machine.user!.imageUrl != null ||
                                            machine.user!.image != null)
                                          Container(
                                            width: 50.w,
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primary,
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    machine.user!.imageUrl ??
                                                    machine
                                                        .user!
                                                        .image
                                                        ?.fullUrl ??
                                                    '',
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                          color: AppColors
                                                              .surfaceVariant,
                                                          child: Icon(
                                                            Icons.person,
                                                            color: AppColors
                                                                .textSecondary,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 50.w,
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color: AppColors.primary,
                                              size: 24.sp,
                                            ),
                                          ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                machine.user!.name,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone,
                                                    size: 14.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    machine.user!.phone,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  SizedBox(height: 12.h),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Builder(
                                        builder: (context) {
                                          final localizations =
                                              AppLocalizations.of(context);
                                          return Text(
                                            '${localizations?.createdAt ?? AppTexts.createdAt}: ${machine.createdAt}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.textTertiary,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isVideoUrl(UsedMachine machine) {
    // Check mimeType first (most reliable indicator)
    if (machine.image?.mimeType != null && machine.image!.mimeType.isNotEmpty) {
      final mimeType = machine.image!.mimeType.toLowerCase().trim();
      if (mimeType.startsWith('video/')) {
        return true;
      }
    }

    // Check file extension as backup
    final url = machine.imageUrlString.trim();
    if (url.isEmpty) return false;

    final urlLower = url.toLowerCase();
    final urlWithoutQuery = urlLower.split('?').first;

    final videoExtensions = [
      '.mp4',
      '.mov',
      '.webm',
      '.avi',
      '.mkv',
      '.flv',
      '.wmv',
      '.m4v',
      '.3gp',
    ];

    // Check if URL ends with any video extension
    return videoExtensions.any((ext) => urlWithoutQuery.endsWith(ext));
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Ensure URL is properly formatted - convert HTTP to use the network security config
      String videoUrl = widget.videoUrl;
      // The network security config should handle HTTP, but ensure it's a valid URI
      final uri = Uri.parse(videoUrl);

      _controller = VideoPlayerController.networkUrl(uri);

      // Set error handler before initialization
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        }
      });

      await _controller!.initialize();
      if (mounted && !_controller!.value.hasError) {
        setState(() {
          _isInitialized = true;
        });
        // Auto-play the video
        _controller!.play();
      } else if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      // Dispose controller on error
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppColors.surfaceVariant,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: AppColors.textSecondary,
              size: 48.sp,
            ),
            SizedBox(height: 8.h),
            Builder(
              builder: (context) {
                final localizations = AppLocalizations.of(context);
                return Text(
                  localizations?.videoUnavailable ?? AppTexts.videoUnavailable,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: AppColors.surfaceVariant,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: _controller!.value.isPlaying
                    ? const SizedBox.shrink()
                    : Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 48.sp,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
