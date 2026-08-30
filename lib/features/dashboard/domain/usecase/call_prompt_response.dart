import '../../data/datasources/image_detail_remote_source.dart';
import '../entities/questiton_entity.dart';

class PromptResponse{

  final dataSource = ImageDetailRemoteDataSource();

  Future<QuestionEntity> call(String imageUrl,String difficulty) async{

    final questionModel = await dataSource.generateQuestionFromImageUrl(
      imageUrl: imageUrl,
      difficulty: difficulty,
    );

    return questionModel.toEntity();

  }

}