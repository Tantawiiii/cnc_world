class MaintenanceImage {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  MaintenanceImage({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory MaintenanceImage.fromJson(Map<String, dynamic> json) {
    return MaintenanceImage(
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

class Maintenance {
  final int id;
  final String problemDetails;
  final String status;
  final String assignedBy;
  final bool active;
  final String? imageUrl;
  final MaintenanceImage? image;
  final String createdAt;
  final String updatedAt;

  Maintenance({
    required this.id,
    required this.problemDetails,
    required this.status,
    required this.assignedBy,
    required this.active,
    this.imageUrl,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'] ?? 0,
      problemDetails: json['problem_details'] ?? '',
      status: json['status'] ?? '',
      assignedBy: json['assigned_by'] ?? '',
      active: json['active'] ?? false,
      imageUrl: json['imageUrl'],
      image: json['image'] != null
          ? MaintenanceImage.fromJson(json['image'])
          : null,
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
}

class UserProfile {
  final int id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String role;
  final String phone;
  final bool active;
  final String createdAt;
  final String updatedAt;
  final String? imageUrl;
  final dynamic image;
  final List<Maintenance> maintenances;
  final String? lat;
  final String? lng;
  final String? workshopName;
  final String? natureOfWork;
  final double rating;
  final int totalReviews;

  UserProfile({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.role,
    required this.phone,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.image,
    required this.maintenances,
    this.lat,
    this.lng,
    this.workshopName,
    this.natureOfWork,
    this.rating = 0,
    this.totalReviews = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final maintenancesList = json['maintenances'] as List<dynamic>? ?? [];
    final ratingRaw = json['rating'];
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      active: json['active'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      image: json['image'],
      maintenances: maintenancesList
          .map((item) => Maintenance.fromJson(item as Map<String, dynamic>))
          .toList(),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      workshopName: json['workshop_name']?.toString(),
      natureOfWork: json['nature_of_work']?.toString(),
      rating: ratingRaw is num
          ? ratingRaw.toDouble()
          : double.tryParse(ratingRaw?.toString() ?? '') ?? 0,
      totalReviews: json['total_reviews'] is int
          ? json['total_reviews'] as int
          : int.tryParse(json['total_reviews']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'address': address,
      'city': city,
      'state': state,
      'active': active,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'imageUrl': imageUrl,
      'image': image is Map<String, dynamic> ? image : null,
      'lat': lat,
      'lng': lng,
      'workshop_name': workshopName,
      'nature_of_work': natureOfWork,
      'rating': rating,
      'total_reviews': totalReviews,
    };
  }
}

class ProfileResponse {
  final UserProfile data;

  ProfileResponse({required this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(data: UserProfile.fromJson(json['data'] ?? {}));
  }
}
