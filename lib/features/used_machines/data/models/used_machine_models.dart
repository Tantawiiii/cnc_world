class UsedMachineImage {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  UsedMachineImage({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory UsedMachineImage.fromJson(Map<String, dynamic> json) {
    return UsedMachineImage(
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

class UsedMachineUser {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String role;
  final String phone;
  final bool active;
  final String createdAt;
  final String updatedAt;
  final String? imageUrl;
  final UsedMachineImage? image;

  UsedMachineUser({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    required this.role,
    required this.phone,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.image,
  });

  factory UsedMachineUser.fromJson(Map<String, dynamic> json) {
    return UsedMachineUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      active: json['active'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      imageUrl: json['imageUrl'],
      image: json['image'] != null
          ? UsedMachineImage.fromJson(json['image'])
          : null,
    );
  }
}

class UsedMachine {
  final int id;
  final String name;
  final String description;
  final String price;
  final bool active;
  final String? imageUrl;
  final UsedMachineImage? image;
  final String createdAt;
  final String updatedAt;
  final UsedMachineUser? user;

  UsedMachine({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.active,
    this.imageUrl,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory UsedMachine.fromJson(Map<String, dynamic> json) {
    return UsedMachine(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '0.00',
      active: json['active'] ?? false,
      imageUrl: json['imageUrl'],
      image: json['image'] != null
          ? UsedMachineImage.fromJson(json['image'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: json['user'] != null
          ? UsedMachineUser.fromJson(json['user'])
          : null,
    );
  }

  String get imageUrlString {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    if (image?.fullUrl != null && image!.fullUrl.isNotEmpty) {
      return image!.fullUrl;
    }
    return '';
  }
}

class UsedMachinesListResponse {
  final List<UsedMachine> data;

  UsedMachinesListResponse({required this.data});

  factory UsedMachinesListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return UsedMachinesListResponse(
      data: dataList
          .map((item) => UsedMachine.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UsedMachineDetailResponse {
  final UsedMachine data;
  final String result;
  final String message;
  final int status;

  UsedMachineDetailResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory UsedMachineDetailResponse.fromJson(Map<String, dynamic> json) {
    return UsedMachineDetailResponse(
      data: UsedMachine.fromJson(json['data'] ?? {}),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}

class AddUsedMachineRequest {
  final String name;
  final double price;
  final String description;
  final int image;

  AddUsedMachineRequest({
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'image': image,
    };
  }
}

class AddUsedMachineResponse {
  final String status;
  final String message;
  final Map<String, dynamic>? data;

  AddUsedMachineResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AddUsedMachineResponse.fromJson(Map<String, dynamic> json) {
    return AddUsedMachineResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
