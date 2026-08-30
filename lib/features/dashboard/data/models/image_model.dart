import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_dashboard/features/dashboard/domain/entities/image_entity.dart';

class ImageModel {
  final String? id;
  final String url;
  final DateTime createdAt;

  ImageModel({this.id, required this.url, required this.createdAt});

  factory ImageModel.fromMap(Map<String, dynamic> json, String docId) {
    return ImageModel(
      id: docId,
      url: json['imageUrl'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'imageUrl': url, 'createdAt': createdAt,};
  }

  ImageEntity toEntity() {
    return ImageEntity(id: id, url: url, createdAt: createdAt,);
  }
}
