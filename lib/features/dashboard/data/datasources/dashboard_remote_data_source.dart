import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_dashboard/features/dashboard/domain/entities/image_entity.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/bb_image_resource.dart';
import '../models/image_model.dart';

class DashboardRemoteDataSource {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BbImageResource> uploadImageToImgBB(Uint8List fileBytes) async {
    try {
      final base64Image = base64Encode(fileBytes);


      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=${AppConstants.imgBbApiKey}'),
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final imageUrl = data['data']['url'] as String;
        final deleteUrl = data['data']['delete_url'] as String;


        return BbImageResource(imageUrl: imageUrl, deleteUrl: deleteUrl);
      } else {
        throw Exception('ImgBB Yükleme Hatası: ${response.body}');
      }
    } catch (e) {
      throw Exception('Resim servise gönderilemedi: $e');
    }
  }

  Future<List<ImageModel>> fetchDashImages({
    String collectionName = 'images',
    String dateField = 'createdAt',
}) async{

    final snapshot = await _firestore.collection(collectionName).orderBy(dateField,descending: true).get();

    return snapshot.docs.map((docItem) => ImageModel.fromMap(docItem.data() as Map<String,dynamic> , docItem.id)).toList();
  }

  Future<ImageEntity> addImage({
    required String url,
    String collectionName = 'images',
    required String deleteUrl
  }) async {

    final imgObj = ImageModel(url: url, createdAt: DateTime.now(), deleteUrl: deleteUrl);

    await _firestore
        .collection(collectionName)
        .add(imgObj.toMap());

    return imgObj.toEntity();
  }

  Future<void> deleteImage({
    required String docId,
    String? deleteUrl,
  }) async {
    try {

      await _firestore.collection('images').doc(docId).delete();
    } catch (e) {
      throw Exception("Silme işlemi başarısız: $e");
    }
  }

}
