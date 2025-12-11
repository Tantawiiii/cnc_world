import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/slider_models.dart';

class SliderRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<SliderResponse> getSliders() async {
    try {
      final response = await _apiService.get(ApiConstants.getSlider);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return SliderResponse.fromJson(response.data as Map<String, dynamic>);
        } else {
          throw Exception('Invalid response format: expected Map');
        }
      } else {
        final errorMessage = response.data is Map
            ? (response.data as Map)['message'] ?? 'Failed to load sliders'
            : 'Failed to load sliders';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
