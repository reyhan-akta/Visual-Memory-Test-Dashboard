import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/question_model.dart';

class ImageDetailRemoteDataSource {

  Future<QuestionModel> generateQuestionFromImageUrl({
    required String imageUrl,
    String apiKey = AppConstants.googleStudioApiKey,
    String modelName = AppConstants.modelName,
    required String difficulty, // 🟢 Ana sayfadan gelen zorluk seviyesi (örn: 'kolay', 'orta', 'zor')
  }) async {

    //Uniform Resource Identifier
    // 1. URL Yapılandırması
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    // 2. Görseli indir ve Base64'e çevir
    final imageResponse = await http.get(Uri.parse(imageUrl));
    if (imageResponse.statusCode != 200) {
      throw Exception('Görsel indirilemedi: ${imageResponse.statusCode}');
    }

    final String mimeType = imageResponse.headers['content-type'] ?? 'image/jpeg';
    final String base64Image = base64Encode(imageResponse.bodyBytes);

    // 3. Prompt & Request Body (3 Şıklı ve Dışarıdan Zorluk Seviyeli)
    final String promptText = '''
Resimdeki nesneleri incele. Bu nesnelere dayanarak "$difficulty" zorluk seviyesinde 3 seçenekli (A, B, C) bir çoktan seçmeli soru oluştur.
Yanıtı SADECE ve SADECE aşağıdaki JSON formatında ver:

{
  "question": "Soru metni buraya",
  "choices": ["A şıkkı", "B şıkkı", "C şıkkı"],
  "correct": "Doğru olan şık metni (choices içindekiyle birebir aynı)",
  "difficulty": "$difficulty"
}
''';

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": promptText},
            {
              "inline_data": {
                "mime_type": mimeType,
                "data": base64Image,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "response_mime_type": "application/json",
        "temperature": 0.4,
      }
    };

    // 4. İsteği At
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> outerJson = jsonDecode(response.body);
      final String rawJsonText =
      outerJson['candidates'][0]['content']['parts'][0]['text'];

      final Map<String, dynamic> questionMap = jsonDecode(rawJsonText);
      return QuestionModel.fromMap(questionMap);
    } else {
      throw Exception('Gemini API Hatası: ${response.statusCode} - ${response.body}');
    }
  }
}