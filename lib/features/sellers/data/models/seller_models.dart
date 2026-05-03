class SellerImage {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  SellerImage({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory SellerImage.fromJson(Map<String, dynamic> json) {
    return SellerImage(
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

class SellerCommentUser {
  final int id;
  final String name;

  SellerCommentUser({
    required this.id,
    required this.name,
  });

  factory SellerCommentUser.fromJson(Map<String, dynamic> json) {
    return SellerCommentUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SellerComment {
  final int id;
  final SellerCommentUser user;
  final String comment;
  final double rate;
  final String createdAt;

  SellerComment({
    required this.id,
    required this.user,
    required this.comment,
    required this.rate,
    required this.createdAt,
  });

  factory SellerComment.fromJson(Map<String, dynamic> json) {
    final rateRaw = json['rate'];
    return SellerComment(
      id: json['id'] ?? 0,
      user: SellerCommentUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      comment: json['comment'] ?? '',
      rate: rateRaw is num
          ? rateRaw.toDouble()
          : double.tryParse(rateRaw?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Seller {
  final int id;
  final String name;
  final String phone;
  final String role;
  final String address;
  final String state;
  final String city;
  final String natureOfWork;
  final String workshopName;
  final double rating;
  final int totalReviews;
  final List<SellerComment> comments;
  final String? imageUrl;
  final SellerImage? image;
  final String? lat;
  final String? lng;

  Seller({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.address,
    required this.state,
    required this.city,
    required this.natureOfWork,
    required this.workshopName,
    required this.rating,
    required this.totalReviews,
    required this.comments,
    this.imageUrl,
    this.image,
    this.lat,
    this.lng,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    final ratingRaw = json['rating'];
    return Seller(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      natureOfWork: json['nature_of_work'] ?? '',
      workshopName: json['workshop_name'] ?? '',
      rating: ratingRaw is num
          ? ratingRaw.toDouble()
          : double.tryParse(ratingRaw?.toString() ?? '0') ?? 0,
      totalReviews: json['total_reviews'] ?? 0,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map(
            (item) => SellerComment.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      imageUrl: json['imageUrl'],
      image: json['image'] != null ? SellerImage.fromJson(json['image']) : null,
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
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

  String get fullAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }
}

class SellersListResponse {
  final List<Seller> data;
  final SellersLinks? links;
  final SellersMeta? meta;

  SellersListResponse({required this.data, this.links, this.meta});

  factory SellersListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return SellersListResponse(
      data: dataList
          .map((item) => Seller.fromJson(item as Map<String, dynamic>))
          .toList(),
      links: json['links'] != null
          ? SellersLinks.fromJson(json['links'])
          : null,
      meta: json['meta'] != null ? SellersMeta.fromJson(json['meta']) : null,
    );
  }
}

class SellersLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  SellersLinks({this.first, this.last, this.prev, this.next});

  factory SellersLinks.fromJson(Map<String, dynamic> json) {
    return SellersLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class SellersMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  SellersMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory SellersMeta.fromJson(Map<String, dynamic> json) {
    return SellersMeta(
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

class SellerDetailResponse {
  final Seller data;
  final String result;
  final String message;
  final int status;

  SellerDetailResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory SellerDetailResponse.fromJson(Map<String, dynamic> json) {
    return SellerDetailResponse(
      data: Seller.fromJson(json['data'] ?? {}),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}
