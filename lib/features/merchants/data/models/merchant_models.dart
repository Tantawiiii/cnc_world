class MerchantImage {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  MerchantImage({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory MerchantImage.fromJson(Map<String, dynamic> json) {
    return MerchantImage(
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

class Merchant {
  final int id;
  final String name;
  final String phone;
  final String role;
  final String? facebookLink;
  final String? whatsappNumber;
  final bool active;
  final String createdAt;
  final String updatedAt;
  final String? imageUrl;
  final MerchantImage? image;

  Merchant({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.facebookLink,
    this.whatsappNumber,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.image,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      facebookLink: json['facebook_link'],
      whatsappNumber: json['whatsapp_number'],
      active: json['active'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      imageUrl: json['imageUrl'],
      image: json['image'] != null
          ? MerchantImage.fromJson(json['image'])
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

class MerchantsListResponse {
  final List<Merchant> data;
  final MerchantsLinks? links;
  final MerchantsMeta? meta;

  MerchantsListResponse({required this.data, this.links, this.meta});

  factory MerchantsListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return MerchantsListResponse(
      data: dataList
          .map((item) => Merchant.fromJson(item as Map<String, dynamic>))
          .toList(),
      links: json['links'] != null
          ? MerchantsLinks.fromJson(json['links'])
          : null,
      meta: json['meta'] != null ? MerchantsMeta.fromJson(json['meta']) : null,
    );
  }
}

class MerchantsLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  MerchantsLinks({this.first, this.last, this.prev, this.next});

  factory MerchantsLinks.fromJson(Map<String, dynamic> json) {
    return MerchantsLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class MerchantsMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  MerchantsMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory MerchantsMeta.fromJson(Map<String, dynamic> json) {
    return MerchantsMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      to: json['to'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class MerchantDetailResponse {
  final Merchant data;
  final String result;
  final String message;
  final int status;

  MerchantDetailResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory MerchantDetailResponse.fromJson(Map<String, dynamic> json) {
    return MerchantDetailResponse(
      data: Merchant.fromJson(json['data'] ?? {}),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}
