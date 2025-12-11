import 'package:dio/dio.dart';

import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_service.dart';
import '../models/company_models.dart';

class CompanyRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<CompaniesListResponse> getCompanies() async {
    try {
      final response = await _apiService.get('/api/get-company');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return CompaniesListResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load companies'
            : 'Failed to load companies';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CompanyDetailResponse> getCompanyDetail(int id) async {
    try {
      final response = await _apiService.get('/api/company/$id');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return CompanyDetailResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Failed to load company details'
            : 'Failed to load company details';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
