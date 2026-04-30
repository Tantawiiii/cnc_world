import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_service.dart';
import '../models/engineer_models.dart';

class EngineerRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<EngineersListResponse> getEngineers({int page = 1}) async {
    try {
      final response = await _apiService.post(
        '/api/engineer/index',
        queryParameters: {'page': page},
        data: {
          'filters': {'role': 'engineer'},
          'orderBy': 'id',
          'orderByDirection': 'desc',
          'perPage': 6,
          'paginate': true,
          'delete': false,
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return EngineersListResponse.fromJson(response.data);
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

  Future<EngineerDetailResponse> getEngineerDetail(int id) async {
    try {
      final response = await _apiService.get('/api/engineer/$id');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return EngineerDetailResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load engineer details'
            : 'Failed to load engineer details';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
