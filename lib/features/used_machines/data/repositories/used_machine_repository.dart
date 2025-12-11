import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/used_machine_models.dart';
import '../../../auth/register/data/models/register_models.dart';

class UsedMachineRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<UsedMachinesListResponse> getUsedMachines() async {
    try {
      final response = await _apiService.get('/api/get-used-machine');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return UsedMachinesListResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load used machines'
            : 'Failed to load used machines';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UsedMachineDetailResponse> getUsedMachineDetail(int id) async {
    try {
      final response = await _apiService.get('/api/used-machine/$id');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return UsedMachineDetailResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load machine details'
            : 'Failed to load machine details';
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

  Future<AddUsedMachineResponse> addUsedMachine(
    AddUsedMachineRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/api/used-machine',
        data: request.toJson(),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return AddUsedMachineResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to add machine'
            : 'Failed to add machine';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
