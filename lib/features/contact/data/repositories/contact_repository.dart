import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/contact_models.dart';

class ContactRepository {
  final ApiService _apiService = di.sl<ApiService>();

  Future<ContactResponse> submitContact(ContactRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.contactUs,
        data: request.toJson(),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        return ContactResponse.fromJson(response.data);
      } else {
        String errorMessage = 'Failed to submit contact request';

        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;

          // Try to get the main message
          if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }

          // Check for field-specific errors (validation errors)
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];

            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessages.addAll(messages.map((m) => m.toString()));
              } else if (messages is String) {
                errorMessages.add(messages);
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
