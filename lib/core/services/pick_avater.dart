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
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) return null;
    } else {
      await Permission.photos.request();
      await Permission.storage.request();
    }

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) return null;

    final cropped = await ImageCropper().cropImage(
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
        ),
        IOSUiSettings(title: AppTexts.cropImage),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }
}
