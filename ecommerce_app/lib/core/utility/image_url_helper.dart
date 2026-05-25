import 'package:ecommerce_app/core/di/network_client.dart';

/// Builds a full URL for API media paths (brands, categories, products).
String? resolveMediaUrl(dynamic value) {
  if (value == null) return null;

  String? raw;
  if (value is String) {
    raw = value.trim();
  } else if (value is Map) {
    raw = (value['url'] ?? value['path'] ?? value['image_url'])?.toString().trim();
  } else {
    raw = value.toString().trim();
  }

  if (raw == null || raw.isEmpty || raw == 'null') return null;

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  final apiBase = NetworkClient.baseUrl;
  final origin = apiBase.replaceFirst(RegExp(r'/api/?$'), '');
  final path = raw.startsWith('/') ? raw : '/$raw';
  return '$origin$path';
}

String? brandImageUrl({
  dynamic imageUrl,
  dynamic image,
  dynamic companyImage,
}) {
  return resolveMediaUrl(imageUrl) ??
      resolveMediaUrl(image) ??
      resolveMediaUrl(companyImage);
}
