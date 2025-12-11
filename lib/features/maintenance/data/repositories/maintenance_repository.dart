import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/maintenance_models.dart';
import '../../../auth/register/data/models/register_models.dart';

class MaintenanceRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<EngineersResponse> getEngineers() async {
    try {
      final response = await _apiService.post('/api/engineer/index', data: {});

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return EngineersResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load engineers'
            : 'Failed to load engineers';
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

  Future<MaintenanceResponse> submitMaintenance(
    MaintenanceRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/api/maintenance',
        data: request.toJson(),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return MaintenanceResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to submit maintenance request'
            : 'Failed to submit maintenance request';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
