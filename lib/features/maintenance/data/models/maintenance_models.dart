class Engineer {
  final int id;
  final String name;
  final String phone;
  final String role;
  final bool active;
  final String createdAt;
  final String updatedAt;

  Engineer({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      active: json['active'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class EngineersResponse {
  final List<Engineer> data;
  final String result;
  final String message;
  final int status;

  EngineersResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory EngineersResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return EngineersResponse(
      data: dataList
          .map((item) => Engineer.fromJson(item as Map<String, dynamic>))
          .where((engineer) => engineer.role == 'engineer')
          .toList(),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
    );
  }
}

class MaintenanceRequest {
  final String problemDetails;
  final int engineerId;
  final String assignedBy;
  final int image;

  MaintenanceRequest({
    required this.problemDetails,
    required this.engineerId,
    required this.assignedBy,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'problem_details': problemDetails,
      'engineer_id': engineerId,
      'assigned_by': assignedBy,
      'image': image,
    };
  }
}

class MaintenanceResponse {
  final String status;
  final String message;
  final Map<String, dynamic>? data;

  MaintenanceResponse({required this.status, required this.message, this.data});

  factory MaintenanceResponse.fromJson(Map<String, dynamic> json) {
    return MaintenanceResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
