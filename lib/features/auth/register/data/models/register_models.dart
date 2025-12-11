enum UserRole {
  user('user'),
  engineer('engineer'),
  seller('seller'),
  merchant('merchant');

  final String value;
  const UserRole(this.value);
}

class RegisterRequest {
  final UserRole role;
  final String name;
  final String phone;
  final String password;
  

  final String? address;
  final String? city;
  final String? state;
  final String? workshopName;
  final String? natureOfWork;
  final String? facebookLink;
  final String? whatsappNumber;
  final int? imageId;

  RegisterRequest({
    required this.role,
    required this.name,
    required this.phone,
    required this.password,
    this.address,
    this.city,
    this.state,
    this.workshopName,
    this.natureOfWork,
    this.facebookLink,
    this.whatsappNumber,
    this.imageId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'role': role.value,
      'name': name,
      'phone': phone,
      'password': password,
    };

    // Add fields based on role
    switch (role) {
      case UserRole.user:
        if (address != null) data['address'] = address;
        if (city != null) data['city'] = city;
        if (state != null) data['state'] = state;
        break;
      case UserRole.engineer:
        // Engineer only needs: role, name, phone, password
        break;
      case UserRole.seller:
        if (workshopName != null) data['workshop_name'] = workshopName;
        if (address != null) data['address'] = address;
        if (city != null) data['city'] = city;
        if (state != null) data['state'] = state;
        if (natureOfWork != null) data['nature_of_work'] = natureOfWork;
        if (imageId != null) data['image'] = imageId;
        break;
      case UserRole.merchant:
        if (facebookLink != null) data['facebook_link'] = facebookLink;
        if (whatsappNumber != null) data['whatsapp_number'] = whatsappNumber;
        if (imageId != null) data['image'] = imageId;
        break;
    }

    return data;
  }
}

class RegisterResponse {
  final String result;
  final dynamic data;
  final String message;
  final int status;

  RegisterResponse({
    required this.result,
    this.data,
    required this.message,
    required this.status,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      result: json['result'] ?? '',
      data: json['data'],
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class MediaUploadResponse {
  final String status;
  final String message;
  final MediaData data;

  MediaUploadResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: MediaData.fromJson(json['data'] ?? {}),
    );
  }
}

class MediaData {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  MediaData({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) {
    return MediaData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      authorId: json['authorId'],
      previewUrl: json['previewUrl'] ?? '',
      fullUrl: json['fullUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
