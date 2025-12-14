import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../constant/app_colors.dart';
import '../constant/app_texts.dart';
import '../services/pick_avater.dart';

extension ImagePickerExtension on BuildContext {
  /// Shows a bottom sheet to select media type and source
  /// Returns MediaPickerResult with type and source or null if cancelled
  Future<MediaPickerResult?> showMediaPicker() async {
    // First show media type selection
    final mediaType = await showModalBottomSheet<MediaType>(
      context: this,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'اختر نوع الملف',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaTypeOption(
                  context,
                  Icons.image_outlined,
                  'صورة',
                  MediaType.image,
                ),
                _buildMediaTypeOption(
                  context,
                  Icons.videocam_outlined,
                  'فيديو',
                  MediaType.video,
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );

    if (mediaType == null || !mounted) return null;

    // Then show source selection
    final source = await showImageSourcePicker();
    if (source == null || !mounted) return null;

    return MediaPickerResult(type: mediaType, source: source);
  }

  /// Shows a bottom sheet to select image source (Camera or Gallery)
  /// Returns the selected ImageSource or null if cancelled
  Future<ImageSource?> showImageSourcePicker() async {
    return await showModalBottomSheet<ImageSource>(
      context: this,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppTexts.selectImageSource,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context,
                  Icons.camera_alt_outlined,
                  AppTexts.camera,
                  ImageSource.camera,
                ),
                _buildImageSourceOption(
                  context,
                  Icons.photo_library_outlined,
                  AppTexts.gallery,
                  ImageSource.gallery,
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build media type option button
  Widget _buildMediaTypeOption(
    BuildContext context,
    IconData icon,
    String label,
    MediaType type,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: AppColors.textOnPrimary),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build image source option button
  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    ImageSource source,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, source),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: AppColors.textOnPrimary),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks and crops an image from the selected source
  /// Returns the File or null if cancelled or failed
  Future<ImageFileResult?> pickAndCropImage() async {
    final source = await showImageSourcePicker();
    if (source == null) return null;

    try {
      final file = await PickAvatarService.pickAvatar(source);
      if (file == null) return null;

      return ImageFileResult(file: file);
    } catch (e) {
      return null;
    }
  }

  /// Picks image or video from the selected source
  /// Returns MediaFileResult or null if cancelled or failed
  Future<MediaFileResult?> pickMedia() async {
    final result = await showMediaPicker();
    if (result == null) return null;

    try {
      File? file;
      if (result.type == MediaType.image) {
        file = await PickAvatarService.pickAvatar(result.source);
      } else {
        file = await PickAvatarService.pickVideo(result.source);
      }

      if (file == null) return null;

      return MediaFileResult(file: file, type: result.type);
    } catch (e) {
      return null;
    }
  }
}

/// Media type enum
enum MediaType { image, video }

/// Result class for media picker operations
class MediaPickerResult {
  final MediaType type;
  final ImageSource source;

  MediaPickerResult({required this.type, required this.source});
}

/// Result class for image picking operations
class ImageFileResult {
  final File file;

  ImageFileResult({required this.file});
}

/// Result class for media file operations
class MediaFileResult {
  final File file;
  final MediaType type;

  MediaFileResult({required this.file, required this.type});
}
