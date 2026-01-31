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

  String get imageUrlString {
    final direct = _cleanUrl(imageUrl);
    if (direct.isNotEmpty) return direct;

    final full = _cleanUrl(image?.fullUrl);
    if (full.isNotEmpty) return full;

    return '';
  }

  String _cleanUrl(String? url) {
    if (url == null) return '';

    final trimmed = url.trim().replaceAll('\n', '').replaceAll('\r', '');
    if (trimmed.isEmpty) return '';

    try {
      Uri? uri = Uri.tryParse(trimmed);
      if (uri == null) return '';

      // توحيد الـ scheme ومسار الرابط
      final scheme = (uri.scheme.isEmpty || uri.scheme == 'http')
          ? 'https'
          : uri.scheme;
      final cleanPath = uri.path.replaceAll(RegExp(r'/+'), '/');

      uri = Uri(
        scheme: scheme,
        userInfo: uri.userInfo,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: cleanPath.startsWith('/') ? cleanPath : '/$cleanPath',
        query: uri.hasQuery ? uri.query : null,
        fragment: uri.fragment.isNotEmpty ? uri.fragment : null,
      );

      return uri.toString();
    } catch (_) {
      return trimmed.replaceAll(RegExp(r'/+'), '/');
    }
  }
}
