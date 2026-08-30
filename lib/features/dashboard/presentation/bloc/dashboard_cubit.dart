import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_dashboard/features/dashboard/presentation/bloc/dashboard_state.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../domain/entities/image_entity.dart';

class DashboardGridCubit extends Cubit<DashboardGridState> {
  DashboardGridCubit() : super(DashboardInitial());

  final DashboardRemoteDataSource dashboardRemoteDataSource =
      DashboardRemoteDataSource();

  Future<void> pickAndUploadVideo(imageUrl) async{

    try{
      emit(VideoLoading());
      final videoUrl = await dashboardRemoteDataSource.uploadVideoToCloudinary();
      print("show me the video url $videoUrl");
      await dashboardRemoteDataSource.updloadVideoToFirebase(imageUrl, videoUrl);
      emit(VideoLoadedSuccessfuly());  
    }catch(e){
      emit(ErrorVideoLoading(message: 'Video yüklerken bir sorun ile karşılaşıldı'));
    }
    
  }

  Future<void> pickAndUploadImage() async {

    List<ImageEntity>? previousImages ;
    String currentDifficultyLevel = '';

    if(state is DashboardLoadedSuccessfuly){
      previousImages = (state as DashboardLoadedSuccessfuly).images;
      currentDifficultyLevel = (state as DashboardLoadedSuccessfuly).difficultyLevel;
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );


      if (result != null && result.files.single.bytes != null) {


        final file = result.files.single;
        final pureData = file.bytes!;

        final prevImages = <ImageEntity?>[null,...?previousImages];
        emit(DashboardLoading(previousImages: prevImages));


        final imageDownloadUrl = await dashboardRemoteDataSource
            .uploadImageToImgBB(pureData);

        final newImageDocId = await dashboardRemoteDataSource.addImage(
          level: currentDifficultyLevel,
          url: imageDownloadUrl.imageUrl,
        );

          final newImageModel = ImageEntity(id: newImageDocId.id, url: imageDownloadUrl.imageUrl, createdAt: DateTime.now(),);


          final updatedList = prevImages.where((e) => e!=null).cast<ImageEntity>().toList();
          updatedList.insert(0,newImageModel);
          emit(DashboardLoadedSuccessfuly(images: updatedList,difficultyLevel: currentDifficultyLevel));




      }
    } catch (e, stackTrace) {
      print('=== DETAYLI HATA BAŞLANGICI ===');
      print('Hata Mesajı: $e');
      print('Stack Trace: $stackTrace');
      print('=== DETAYLI HATA BİTİŞİ ===');

      emit(DashboardError(e.toString()));
    }
  }

  Future<void> fetchImages() async {

    List<ImageEntity>? previousImages ;


    if(state is DashboardLoadedSuccessfuly){
      previousImages = (state as DashboardLoadedSuccessfuly).images;
    }

    emit(DashboardLoading(previousImages: previousImages));

    try {
      final imageCloudData = await dashboardRemoteDataSource.fetchDashImages('Kolay');
      final imageEntities = imageCloudData.map((e) => e.toEntity()).toList();
      emit(DashboardLoadedSuccessfuly(images: imageEntities,difficultyLevel: 'Kolay'));
    } catch (e) {
      emit(DashboardError("Resimler çekilirken hata oluştu: $e"));
    }
  }

  Future<void> deleteImage(String docId) async {
    if (state is! DashboardLoadedSuccessfuly) return;

    final currentState = state as DashboardLoadedSuccessfuly;
    final currentList = currentState.images;
    final currentDifficultyLevel = currentState.difficultyLevel;
    
    final imageToDelete = currentList.firstWhere(
          (img) => (img as ImageEntity).id == docId,
    ) as ImageEntity;
    
    final updatedList = currentList
        .where((img) => (img as ImageEntity).id != docId)
        .toList();
    emit(DashboardLoadedSuccessfuly(images: updatedList,difficultyLevel: currentDifficultyLevel));

    try {
      await dashboardRemoteDataSource.deleteImage(
        level: currentDifficultyLevel,
        docId: docId,
      );
    } catch (e) {
     // emit(DashboardLoadedSuccessfuly(images: currentList));
    }
  }

  changeDifficulty(String newLevel){

    List<ImageEntity>? currentImages;

    if(state is DashboardLoadedSuccessfuly){
      currentImages = (state as DashboardLoadedSuccessfuly).images;
    }

    emit(DashboardLoadedSuccessfuly(images: currentImages ?? [],difficultyLevel: newLevel));

  }

}
