class ContactRequest {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String subject;
  final String message;
  final String type; // "contact" or "complaint"

  ContactRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.subject,
    required this.message,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'subject': subject,
      'message': message,
      'type': type,
    };
  }
}

class ContactResponse {
  final bool success;
  final String? message;
  final dynamic data;

  ContactResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'],
    );
  }
}

