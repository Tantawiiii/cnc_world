import '../../../auth/login/data/models/login_models.dart';

class SliderResponse {
  final List<SliderItem> data;

  SliderResponse({required this.data});

  factory SliderResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    return SliderResponse(
      data: dataList.map((item) => SliderItem.fromJson(item)).toList(),
    );
  }
}

class SliderItem {
  final int id;
  final String? text;
  final String? description;
  final bool active;
  final String? imageUrl;
  final ImageData? image;

  SliderItem({
    required this.id,
    this.text,
    this.description,
    required this.active,
    this.imageUrl,
    this.image,
  });

  factory SliderItem.fromJson(Map<String, dynamic> json) {
    return SliderItem(
      id: json['id'] ?? 0,
      text: json['text'],
      description: json['description'],
      active: json['active'] ?? false,
      imageUrl: json['imageUrl'],
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
    );
  }
}
