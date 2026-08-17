class ImageEntity {
  final String? id;
  final String url;
  final DateTime createdAt;
  final String deleteUrl;

  const ImageEntity({
    required this.id,
    required this.url,
    required this.createdAt,
    required this.deleteUrl
  });
}