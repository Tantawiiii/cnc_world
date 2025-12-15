import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_service.dart';
import '../models/seller_models.dart';

class SellerRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<SellersListResponse> getSellers({int? page}) async {
    try {
      final response = await _apiService.get(
        '/api/get-seller',
        queryParameters: page != null ? {'page': page} : null,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return SellersListResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load sellers'
            : 'Failed to load sellers';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<SellerDetailResponse> getSellerDetail(int id) async {
    try {
      final response = await _apiService.get('/api/seller/$id');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return SellerDetailResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load seller details'
            : 'Failed to load seller details';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
