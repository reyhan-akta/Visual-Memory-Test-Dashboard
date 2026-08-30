import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_dashboard/features/dashboard/domain/entities/image_entity.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/bb_image_resource.dart';
import '../models/image_model.dart';

class DashboardRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _mainCollection = 'images_dashboard';
  final String _subCollection = 'items';

  Future<BbImageResource> uploadImageToImgBB(Uint8List fileBytes) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.imageCloudName}/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = AppConstants.imageUploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['secure_url'];
        return BbImageResource(imageUrl: imageUrl);
      } else {
        throw Exception('Cloudinary Yükleme Hatası: ${response.body}');
      }
    } catch (e) {
      throw Exception('Resim servise gönderilemedi: $e');
    }
  }

  Future<String?> uploadVideoToCloudinary() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) return null;

      final bytes = result.files.single.bytes!;

      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/${AppConstants.imageCloudName}/video/upload",
      );

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = AppConstants.imageUploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: result.files.single.name,
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final jsonResponse = jsonDecode(utf8.decode(responseData));
        return jsonResponse['secure_url']; // Yüklenen videonun Cloudinary bağlantısı
      }
    } catch (e) {
      print("video yüklemede bir sorun oluştu $e");
    }

    return null;
  }

  Future<void> updloadVideoToFirebase(imageUrl, videoUrl) async {
    try {
      final querySnasphot = await FirebaseFirestore.instance
          .collectionGroup('items')
          .where('imageUrl', isEqualTo: imageUrl)
          .limit(1)
          .get();

      if(querySnasphot.docs.isNotEmpty){
        final docRef = querySnasphot.docs.first.reference;

        await docRef.update({
          'videoUrl':videoUrl
        });
      }else{
        print('Eşleşen görsel bulunamadı.');
      }

    } catch (e, stackTrace) {
      print("--- FIREBASE HATA DETAYI ---");
      print(e);
      print(stackTrace);
      rethrow; // Hatayı Cubit'e fırlatır
    }
  }

  Future<List<ImageModel>> fetchDashImages(
    String level, {
    String dateField = 'createdAt',
  }) async {
    final docKey = level.toLowerCase();
    final snapshot = await _firestore
        .collection(_mainCollection)
        .doc(docKey)
        .collection(_subCollection)
        .orderBy(dateField, descending: true)
        .get();

    return snapshot.docs
        .map(
          (docItem) => ImageModel.fromMap(
            docItem.data() as Map<String, dynamic>,
            docItem.id,
          ),
        )
        .toList();
  }

  Future<ImageEntity> addImage({
    required String level,
    required String url,
    String collectionName = 'images',
  }) async {
    final docKey = level.toLowerCase();
    final imgObj = ImageModel(url: url, createdAt: DateTime.now());

    await _firestore
        .collection(_mainCollection)
        .doc(docKey)
        .collection(_subCollection)
        .add(imgObj.toMap());

    return imgObj.toEntity();
  }

  Future<void> deleteImage({
    required String level,
    required String docId,
    String? deleteUrl,
  }) async {
    final docKey = level.toLowerCase();

    try {
      await _firestore
          .collection(_mainCollection)
          .doc(docKey)
          .collection(_subCollection)
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception("Silme işlemi başarısız: $e");
    }
  }
}
