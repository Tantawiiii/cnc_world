import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant/app_colors.dart';
import '../constant/app_texts.dart';

class PickAvatarService {
  static final ImagePicker _picker = ImagePicker();
  
  static Future<File?> pickAvatar(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return null;
      } else {
        final photosStatus = await Permission.photos.request();
        final storageStatus = await Permission.storage.request();
        if (!photosStatus.isGranted && !storageStatus.isGranted) {
          return null;
        }
      }

      // Pick image with proper error handling
      XFile? file;
      try {
        file = await _picker.pickImage(
          source: source,
          imageQuality: 90,
          requestFullMetadata: false,
        );
      } catch (e) {
        // Handle picker errors gracefully
        return null;
      }
      
      if (file == null) return null;

      // Crop image with proper error handling
      CroppedFile? cropped;
      try {
        cropped = await ImageCropper().cropImage(
          sourcePath: file.path,
          compressQuality: 95,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppTexts.cropImage,
              toolbarColor: AppColors.primaryColor,
              toolbarWidgetColor: Colors.white,
              statusBarColor: AppColors.primaryColor,
              backgroundColor: Colors.black,
              hideBottomControls: false,
              lockAspectRatio: false,
              initAspectRatio: CropAspectRatioPreset.original,
            ),
            IOSUiSettings(
              title: AppTexts.cropImage,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
              ],
            ),
          ],
        );
      } catch (e) {
        // If cropping fails, return the original file
        return File(file.path);
      }

      if (cropped == null) return null;
      return File(cropped.path);
    } catch (e) {
      // Catch any other errors and return null
      return null;
    }
  }

  /// Picks a video from the selected source
  static Future<File?> pickVideo(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) return null;
      } else {
        final photosStatus = await Permission.photos.request();
        final storageStatus = await Permission.storage.request();
        if (!photosStatus.isGranted && !storageStatus.isGranted) {
          return null;
        }
      }

      // Pick video with proper error handling
      XFile? file;
      try {
        file = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(minutes: 5),
        );
      } catch (e) {
        // Handle picker errors gracefully
        return null;
      }
      
      if (file == null) return null;
      return File(file.path);
    } catch (e) {
      // Catch any other errors and return null
      return null;
    }
  }
}
