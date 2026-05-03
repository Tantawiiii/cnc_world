class EngineerCommentUser {
  final int id;
  final String name;

  EngineerCommentUser({
    required this.id,
    required this.name,
  });

  factory EngineerCommentUser.fromJson(Map<String, dynamic> json) {
    return EngineerCommentUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class EngineerComment {
  final int id;
  final EngineerCommentUser user;
  final String comment;
  final double rate;
  final String createdAt;

  EngineerComment({
    required this.id,
    required this.user,
    required this.comment,
    required this.rate,
    required this.createdAt,
  });

  factory EngineerComment.fromJson(Map<String, dynamic> json) {
    final rateRaw = json['rate'];
    final parsedRate = rateRaw is num
        ? rateRaw.toDouble()
        : double.tryParse(rateRaw?.toString() ?? '0') ?? 0;

    return EngineerComment(
      id: json['id'] ?? 0,
      user: EngineerCommentUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      comment: json['comment'] ?? '',
      rate: parsedRate,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Engineer {
  final int id;
  final String name;
  final String phone;
  final String role;
  final bool active;
  final String createdFrom;
  final String createdAt;
  final String updatedAt;
  final double rating;
  final int totalReviews;
  final double? lat;
  final double? lng;
  final List<EngineerComment> comments;

  Engineer({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.active,
    required this.createdFrom,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
    required this.totalReviews,
    required this.lat,
    required this.lng,
    required this.comments,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    final ratingRaw = json['rating'];
    final latRaw = json['lat'];
    final lngRaw = json['lng'];

    return Engineer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      active: json['active'] ?? false,
      createdFrom: json['created_from'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      rating: ratingRaw is num
          ? ratingRaw.toDouble()
          : double.tryParse(ratingRaw?.toString() ?? '0') ?? 0,
      totalReviews: json['total_reviews'] ?? 0,
      lat: latRaw is num ? latRaw.toDouble() : double.tryParse('$latRaw'),
      lng: lngRaw is num ? lngRaw.toDouble() : double.tryParse('$lngRaw'),
      comments:
          (json['comments'] as List<dynamic>? ?? [])
              .map((item) => EngineerComment.fromJson(item))
              .toList(),
    );
  }
}

class EngineersLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  EngineersLinks({this.first, this.last, this.prev, this.next});

  factory EngineersLinks.fromJson(Map<String, dynamic> json) {
    return EngineersLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class EngineersMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  EngineersMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory EngineersMeta.fromJson(Map<String, dynamic> json) {
    return EngineersMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 6,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class EngineersListResponse {
  final List<Engineer> data;
  final EngineersLinks? links;
  final EngineersMeta? meta;
  final String result;
  final String message;
  final int status;

  EngineersListResponse({
    required this.data,
    required this.links,
    required this.meta,
    required this.result,
    required this.message,
    required this.status,
  });

  factory EngineersListResponse.fromJson(Map<String, dynamic> json) {
    return EngineersListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Engineer.fromJson(item))
          .toList(),
      links: json['links'] != null ? EngineersLinks.fromJson(json['links']) : null,
      meta: json['meta'] != null ? EngineersMeta.fromJson(json['meta']) : null,
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}

class EngineerDetailResponse {
  final Engineer data;
  final String result;
  final String message;
  final int status;

  EngineerDetailResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory EngineerDetailResponse.fromJson(Map<String, dynamic> json) {
    return EngineerDetailResponse(
      data: Engineer.fromJson(json['data'] ?? <String, dynamic>{}),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}
