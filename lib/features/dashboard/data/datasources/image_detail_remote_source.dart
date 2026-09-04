import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/question_model.dart';

class ImageDetailRemoteDataSource {
  Future<(List<QuestionModel> question, String rawJson)>
  generateQuestionFromImageUrl({
    required String imageUrl,
    String apiKey = AppConstants.googleStudioApiKey,
    String modelName = AppConstants.modelName,
    required String difficulty,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    final imageResponse = await http.get(Uri.parse(imageUrl));
    if (imageResponse.statusCode != 200) {
      throw Exception('Görsel indirilemedi: ${imageResponse.statusCode}');
    }

    final String mimeType =
        imageResponse.headers['content-type'] ?? 'image/jpeg';
    final String base64Image = base64Encode(imageResponse.bodyBytes);

    final String promptText =
    '''
Resimdeki nesneleri ve detayları dikkatlice incele. Bu resme dayanarak "$difficulty" zorluk seviyesinde, 3 seçenekli (A, B, C) olacak şekilde rastgele 5 ile 10 arasında çoktan seçmeli soru oluştur.

Yanıtı SADECE ve SADECE aşağıdaki JSON formatında ver:

{
  "total_questions": 6,
  "questions": [
    {
      "question": "Soru metni buraya",
      "choices": ["A şıkkı", "B şıkkı", "C şıkkı"],
      "correct": "Doğru olan şık metni (choices içindekiyle birebir aynı)",
      "difficulty": "$difficulty"
    }
  ]
}
''';

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": promptText},
            {
              "inline_data": {"mime_type": mimeType, "data": base64Image},
            },
          ],
        },
      ],
      "generationConfig": {
        "response_mime_type": "application/json",
        "temperature": 0.4,
      },
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> outerJson = jsonDecode(response.body);
      final String rawJsonText =
      outerJson['candidates'][0]['content']['parts'][0]['text'];

      final Map<String, dynamic> parsedJson = jsonDecode(rawJsonText);
      final List<dynamic> questionsList = parsedJson['questions'] ?? [];

      // QuestionModel listen:
      final List<QuestionModel> questions = questionsList
          .map((item) => QuestionModel.fromMap(item as Map<String, dynamic>))
          .toList();

      return (questions, rawJsonText);
    } else {
      throw Exception(
        'Gemini API Hatası: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> uploadQuestionToCloud(
      List<QuestionModel> questions,
      String difficultyLevel,
      String docId, {
        String collectionName = 'images_dashboard',
        String subCollectionName = 'items',
        String sSubCollectionName = 'questions',
      }) async {
    try {
      final formattedLevel = difficultyLevel.toLowerCase();

      for (var question in questions) {

        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(formattedLevel)
            .collection(subCollectionName)
            .doc(docId)
            .collection(sSubCollectionName)
            .doc()
            .set(question.toMap());
      }
    } catch (e) {
      print("soruları clouda yüklemede bir sorun ile karşılaşıldı $e");
    }
  }

  Future<bool> checkQuestionsExistence(
      String difficultyLevel,
      String imageId,
  {
    String collectionName = 'images_dashboard',
    String subCollectionName = 'items',
    String sSubCollectionName = 'questions',
}
      ) async{

    try{

      final snapshot = await  FirestoreService().db.
      collection(collectionName).
      doc(difficultyLevel.toLowerCase()).
      collection(subCollectionName).
      doc(imageId).collection(sSubCollectionName).get();

      if(snapshot.docs.isNotEmpty){
        return true;
      }else{
        return false;
      }


    }catch(e){
      print("soru kontrolünde bir hata ile karşılaşıldı $e");
    }

    return false;
  }
}