class DesignFile {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  DesignFile({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory DesignFile.fromJson(Map<String, dynamic> json) {
    return DesignFile(
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

class Design {
  final int id;
  final String name;
  final String price;
  final bool active;
  final String? imageUrl;
  final DesignFile? image;
  final String? fileUrl;
  final DesignFile? file;
  final String createdAt;
  final String updatedAt;

  Design({
    required this.id,
    required this.name,
    required this.price,
    required this.active,
    this.imageUrl,
    this.image,
    this.fileUrl,
    this.file,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Design.fromJson(Map<String, dynamic> json) {
    return Design(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? '0.00',
      active: json['active'] ?? false,
      imageUrl: json['imageUrl'],
      image: json['image'] != null ? DesignFile.fromJson(json['image']) : null,
      fileUrl: json['fileUrl'],
      file: json['file'] != null ? DesignFile.fromJson(json['file']) : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
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

  String get fileUrlString {
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      return fileUrl!;
    }
    if (file?.fullUrl != null && file!.fullUrl.isNotEmpty) {
      return file!.fullUrl;
    }
    return '';
  }
}

class DesignsListResponse {
  final List<Design> data;
  final DesignsLinks? links;
  final DesignsMeta? meta;
  final String result;
  final String message;
  final int status;

  DesignsListResponse({
    required this.data,
    this.links,
    this.meta,
    required this.result,
    required this.message,
    required this.status,
  });

  factory DesignsListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return DesignsListResponse(
      data: dataList
          .map((item) => Design.fromJson(item as Map<String, dynamic>))
          .toList(),
      links: json['links'] != null
          ? DesignsLinks.fromJson(json['links'])
          : null,
      meta: json['meta'] != null ? DesignsMeta.fromJson(json['meta']) : null,
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}

class DesignsLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  DesignsLinks({this.first, this.last, this.prev, this.next});

  factory DesignsLinks.fromJson(Map<String, dynamic> json) {
    return DesignsLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class DesignsMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  DesignsMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory DesignsMeta.fromJson(Map<String, dynamic> json) {
    return DesignsMeta(
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

class AddDesignRequest {
  final String name;
  final double price;
  final int active;
  final int? file;
  final int? image;

  AddDesignRequest({
    required this.name,
    required this.price,
    required this.active,
    this.file,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'active': active,
      if (file != null) 'file': file,
      if (image != null) 'image': image,
    };
  }
}

class AddDesignResponse {
  final Design data;
  final String result;
  final String message;
  final int status;

  AddDesignResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory AddDesignResponse.fromJson(Map<String, dynamic> json) {
    return AddDesignResponse(
      data: Design.fromJson(json['data'] ?? {}),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}
