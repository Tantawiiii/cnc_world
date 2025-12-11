class LoginRequest {
  final String phone;
  final String password;

  LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toFormData() {
    return {'phone': phone, 'password': password};
  }
}

class LoginResponse {
  final String message;
  final String type;
  final String token;
  final UserData data;

  LoginResponse({
    required this.message,
    required this.type,
    required this.token,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      token: json['token'] ?? '',
      data: UserData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
      'token': token,
      'data': data.toJson(),
    };
  }
}

class UserData {
  final int id;
  final String name;
  final String phone;
  final String role;
  final String? address;
  final String? city;
  final String? state;
  final String? facebookLink;
  final String? whatsappNumber;
  final bool active;
  final String createdAt;
  final String updatedAt;
  final String? imageUrl;
  final ImageData? image;

  UserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.address,
    this.city,
    this.state,
    this.facebookLink,
    this.whatsappNumber,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.image,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      facebookLink: json['facebook_link'],
      whatsappNumber: json['whatsapp_number'],
      active: json['active'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      imageUrl: json['imageUrl'],
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'address': address,
      'city': city,
      'state': state,
      'facebook_link': facebookLink,
      'whatsapp_number': whatsappNumber,
      'active': active,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'imageUrl': imageUrl,
      'image': image?.toJson(),
    };
  }
}

class ImageData {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  ImageData({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'size': size,
      'authorId': authorId,
      'previewUrl': previewUrl,
      'fullUrl': fullUrl,
      'createdAt': createdAt,
    };
  }
}
