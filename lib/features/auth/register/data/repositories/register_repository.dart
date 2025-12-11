import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../../core/di/inject.dart' as di;
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../models/register_models.dart';

class RegisterRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await _apiService.post(
        ApiConstants.register,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return RegisterResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Registration failed'
            : 'Registration failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaUploadResponse> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        ApiConstants.mediaUpload,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return MediaUploadResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Image upload failed'
            : 'Image upload failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
