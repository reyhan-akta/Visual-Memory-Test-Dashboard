import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_dashboard/main.dart';
import '../../../data/models/question_model.dart';
import '../../../domain/usecase/call_prompt_response.dart';
import 'image_detail_state.dart';


class ImageDetailCubit extends Cubit<ImageDetailState> {

  ImageDetailCubit():super(ImageDetailStateInitial());


  final promptResponseCase = PromptResponse();

  Future<void> checkCloudExists(String difficultyLevel, String imageId,) async{

    try{

      bool checkExistence =  await promptResponseCase.callToCheck(difficultyLevel,imageId);
      final cachedData = appStorage.read('prompt_json_response_$imageId');

      if(checkExistence){
        emit(CloudUploadSuccessState(rowJson: cachedData ?? '{"message": "Veriler Cloud üzerinde mevcut."}'));
      }

    }catch(e){
      print("Cloud kontrol hatası: $e");
    }

  }

  void checkAndLoadFromCache(String? imageId) async{
    if (imageId == null) return;

    final cachedJson = await appStorage.read('prompt_json_response_$imageId');

    if (cachedJson != null && cachedJson.toString().isNotEmpty) {
      emit(JsonResponseLoaded(rowJson: cachedJson.toString()));
    }
  }

  // ImageDetailCubit içinde:
  Future<void> sendPromptRequest(String imageId,String imageUrl, String difficulty) async {
    try {
      print('🚀 [Cubit] İstek başlatıldı. ImageURL: $imageUrl | Zorluk: $difficulty');

      emit(JsonResponseLoading());

      final (question, rawJson) = await promptResponseCase.call(imageUrl, difficulty);
      await appStorage.write('prompt_json_response_$imageId', rawJson);

      print('✅ [Cubit] Başarıyla veri alındı.');
      print('📄 [Cubit] Raw JSON: $rawJson');

      emit(JsonResponseLoaded(rowJson: rawJson));
    } catch (e, stackTrace) {
      print('❌ [Cubit] Hata oluştu: $e');
      print('🔍 [Cubit] StackTrace: $stackTrace');

      // Hata durumunda ekranda takılı kalmaması için error state'i fırlatıyoruz
      emit(JsonResponseError(message: e.toString()));
    }
  }


  Future<void> decodeJsonData(String rowText, String difficultyLevel, String imageId) async {
    // 1. Ekranı bozmadan sadece yükleme durumuna geçiriyoruz
    emit(CloudUploadingState(rowJson: rowText));

    try {
      final Map<String, dynamic> parsedJson = jsonDecode(rowText);
      final List<dynamic> questionsList = parsedJson['questions'] ?? [];

      final List<QuestionModel> questions = questionsList
          .map((item) => QuestionModel.fromMap(item as Map<String, dynamic>))
          .toList();

      await promptResponseCase.callToUpload(questions, difficultyLevel, imageId);

      // 2. Başarılı state emit ediyoruz
      emit(CloudUploadSuccessState(rowJson: rowText));
    } catch (e) {
      // Hata durumunda JSON görünmeye devam etsin diye tekrar loaded state'e dönüyoruz
      emit(JsonResponseLoaded(rowJson: rowText));
    }
  }

}


