import 'package:image_dashboard/features/dashboard/data/models/question_model.dart';

import '../../data/datasources/image_detail_remote_source.dart';
import '../entities/questiton_entity.dart';

class PromptResponse {
  final dataSource = ImageDetailRemoteDataSource();

  Future<(List<QuestionEntity> question, String rawJson)> call(
    String imageUrl,
    String difficulty,
  ) async {
    final (questionModel, rawJsonText) = await dataSource
        .generateQuestionFromImageUrl(
          imageUrl: imageUrl,
          difficulty: difficulty,
        );
    
    return (questionModel.map((e) => e.toEntity()).toList(), rawJsonText);
  }

  Future<void> callToUpload(List<QuestionModel> questionModel,String difficultyLevel, String docId,) async{

    await dataSource.uploadQuestionToCloud(questionModel, difficultyLevel, docId);


  }

  Future<bool> callToCheck(String difficultyLevel, String imageId,) async{

    return await dataSource.checkQuestionsExistence(difficultyLevel, imageId);
  }

}
