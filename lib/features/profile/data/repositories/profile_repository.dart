import '../../../../core/di/inject.dart' as di;
import '../../../../core/errors/session_unauthorized_exception.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<ProfileResponse> checkAuth() async {
    try {
      final response = await _apiService.get(ApiConstants.checkAuth);

      final status = response.statusCode ?? 0;
      if (status == 401 || status == 403) {
        throw SessionUnauthorizedException();
      }

      if (status >= 200 &&
          status < 300 &&
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

  Future<void> updateLocation({required String lat, required String lng}) async {
    final response = await _apiService.post(
      ApiConstants.updateLocation,
      data: {'lat': lat, 'lng': lng},
    );
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      final errorMessage = response.data is Map
          ? response.data['message'] ?? 'Failed to update location'
          : 'Failed to update location';
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _apiService.get('/api/user/delete-account');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to delete account'
            : 'Failed to delete account';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
