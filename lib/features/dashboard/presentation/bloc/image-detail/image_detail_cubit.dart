import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/call_prompt_response.dart';
import 'image_detail_state.dart';


class ImageDetailCubit extends Cubit<ImageDetailState> {

  ImageDetailCubit():super(ImageDetailStateInitial());


  final promptResponseCase = PromptResponse();

  // ImageDetailCubit içinde:
  Future<void> sendPromptRequest(String imageUrl, String difficulty) async {
    emit(JsonResponseLoading());

    try {

     // await promptResponseCase.call(imageUrl,difficulty);

    //  emit(ImageDetailLoaded(question: questionModel));
    } catch (e) {
    //  emit(ImageDetailError(message: e.toString()));
    }
  }

}

