import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_service.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<ProfileResponse> checkAuth() async {
    try {
      final response = await _apiService.get('/api/check-auth');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return ProfileResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load profile'
            : 'Failed to load profile';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
