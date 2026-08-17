import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_dashboard/features/dashboard/domain/entities/image_entity.dart';

class ImageModel {
  final String? id;
  final String url;
  final DateTime createdAt;
  final String deleteUrl;

  ImageModel({this.id, required this.url, required this.createdAt, required this.deleteUrl});

  factory ImageModel.fromMap(Map<String, dynamic> json, String docId) {
    return ImageModel(
      id: docId,
      url: json['imageUrl'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deleteUrl:  json['deleteUrl']
    );
  }

  Map<String, dynamic> toMap() {
    return {'imageUrl': url, 'createdAt': createdAt, 'deleteUrl':deleteUrl};
  }

  ImageEntity toEntity() {
    return ImageEntity(id: id, url: url, createdAt: createdAt, deleteUrl: deleteUrl);
  }
}
