class CompanyImage {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  CompanyImage({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory CompanyImage.fromJson(Map<String, dynamic> json) {
    return CompanyImage(
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

class CompanyProduct {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final CompanyImage? image;
  final String createdAt;

  CompanyProduct({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.image,
    required this.createdAt,
  });

  factory CompanyProduct.fromJson(Map<String, dynamic> json) {
    return CompanyProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      image: json['image'] != null
          ? CompanyImage.fromJson(json['image'])
          : null,
      createdAt: json['createdAt'] ?? '',
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

class Company {
  final int id;
  final String role;
  final String companyName;
  final String companyDescription;
  final String phone;
  final String companyAddress;
  final bool active;
  final List<CompanyProduct> products;
  final String createdAt;
  final String updatedAt;
  final String? imageUrl;
  final CompanyImage? image;

  Company({
    required this.id,
    required this.role,
    required this.companyName,
    required this.companyDescription,
    required this.phone,
    required this.companyAddress,
    required this.active,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.image,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List<dynamic>? ?? [];
    return Company(
      id: json['id'] ?? 0,
      role: json['role'] ?? '',
      companyName: json['company_name'] ?? '',
      companyDescription: json['company_description'] ?? '',
      phone: json['phone'] ?? '',
      companyAddress: json['company_address'] ?? '',
      active: json['active'] ?? false,
      products: productsList
          .map((item) => CompanyProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      imageUrl: json['imageUrl'],
      image: json['image'] != null
          ? CompanyImage.fromJson(json['image'])
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

class CompaniesListResponse {
  final List<Company> data;

  CompaniesListResponse({required this.data});

  factory CompaniesListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return CompaniesListResponse(
      data: dataList
          .map((item) => Company.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CompanyDetailResponse {
  final Company data;
  final String result;
  final String message;
  final int status;

  CompanyDetailResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory CompanyDetailResponse.fromJson(Map<String, dynamic> json) {
    return CompanyDetailResponse(
      data: Company.fromJson(json['data'] ?? {}),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}
