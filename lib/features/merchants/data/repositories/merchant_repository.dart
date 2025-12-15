import 'package:dio/dio.dart';

import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_service.dart';
import '../models/merchant_models.dart';

class MerchantRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<MerchantsListResponse> getMerchants({int? page}) async {
    try {
      final response = await _apiService.get(
        '/api/get-merchant',
        queryParameters: page != null ? {'page': page} : null,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return MerchantsListResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load merchants'
            : 'Failed to load merchants';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MerchantDetailResponse> getMerchantDetail(int id) async {
    try {
      final response = await _apiService.get('/api/merchant/$id');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return MerchantDetailResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load merchant details'
            : 'Failed to load merchant details';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
