import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PickAvatarService {
  static final ImagePicker _picker = ImagePicker();

  static Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      return true;
    }

    final photosStatus = await Permission.photos.request();
    return photosStatus.isGranted || photosStatus.isLimited;
  }

  static Future<File?> pickAvatar(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        if (!Platform.isAndroid) {
          final status = await Permission.camera.request();
          if (!status.isGranted) return null;
        }
      } else {
        final hasGalleryPermission = await _requestGalleryPermission();
        if (!hasGalleryPermission) {
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
      return File(file.path);
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
        if (!Platform.isAndroid) {
          final cameraStatus = await Permission.camera.request();
          if (!cameraStatus.isGranted) return null;
        }
      } else {
        final hasGalleryPermission = await _requestGalleryPermission();
        if (!hasGalleryPermission) {
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
