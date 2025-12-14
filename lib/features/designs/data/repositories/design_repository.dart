import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/design_models.dart';

class DesignRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<DesignsListResponse> getDesigns({int? page}) async {
    try {
      final response = await _apiService.get(
        '/api/design',
        queryParameters: page != null ? {'page': page} : null,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return DesignsListResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load designs'
            : 'Failed to load designs';
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

  Future<MediaUploadResponse> uploadFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
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
            ? response.data['message'] ?? 'File upload failed'
            : 'File upload failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AddDesignResponse> addDesign(AddDesignRequest request) async {
    try {
      final response = await _apiService.post(
        '/api/design',
        data: request.toJson(),
      );

      print('DesignRepository: addDesign response received');
      print('  statusCode: ${response.statusCode}');
      print('  data: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data != null) {
          print('DesignRepository: Parsing response data');
          final parsedResponse = AddDesignResponse.fromJson(response.data);
          print('DesignRepository: Response parsed successfully');
          return parsedResponse;
        } else {
          print(
            'DesignRepository: response.data is null, creating empty response',
          );
          // Return success response even if data is null
          // Extract message from response if available
          final message =
              response.data is Map && response.data['message'] != null
              ? response.data['message']
              : 'Item has been added successfully';
          return AddDesignResponse(
            data: null,
            result: response.data is Map && response.data['result'] != null
                ? response.data['result']
                : 'Success',
            message: message,
            status: response.statusCode ?? 200,
          );
        }
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to add design'
            : 'Failed to add design';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DesignRepository: addDesign error: $e');
      rethrow;
    }
  }

  Future<void> downloadFile(String url, String savePath) async {
    try {
      // تنزيل الملف مباشرة من URL بدون أي API call
      // استخدام Dio مباشرة للتنزيل من URL العام
      final dio = Dio();
      await dio.download(
        url,
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class MediaUploadResponse {
  final String status;
  final String message;
  final MediaData data;

  MediaUploadResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: MediaData.fromJson(json['data'] ?? {}),
    );
  }
}

class MediaData {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  MediaData({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) {
    return MediaData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      authorId: json['authorId'],
      previewUrl: json['previewUrl'] ?? '',
      fullUrl: json['fullUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
