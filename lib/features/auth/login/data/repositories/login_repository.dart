import 'package:dio/dio.dart';

import '../../../../../core/di/inject.dart' as di;
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../models/login_models.dart';

class LoginRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final formData = FormData.fromMap(request.toFormData());

      final response = await _apiService.post(
        ApiConstants.login,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return LoginResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Login failed'
            : 'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
