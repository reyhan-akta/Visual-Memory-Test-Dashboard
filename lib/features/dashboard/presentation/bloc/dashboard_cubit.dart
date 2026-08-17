import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_dashboard/features/dashboard/presentation/bloc/dashboard_state.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../domain/entities/image_entity.dart';

class DashboardGridCubit extends Cubit<DashboardGridState> {
  DashboardGridCubit() : super(DashboardInitial());

  final DashboardRemoteDataSource dashboardRemoteDataSource =
      DashboardRemoteDataSource();

  Future<void> pickAndUploadImage() async {

    List<ImageEntity>? previousImages ;

    if(state is DashboardLoadedSuccessfuly){
      previousImages = (state as DashboardLoadedSuccessfuly).images;
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
          url: imageDownloadUrl.imageUrl,
          deleteUrl: imageDownloadUrl.deleteUrl
        );

          final newImageModel = ImageEntity(id: newImageDocId.id, url: imageDownloadUrl.imageUrl, createdAt: DateTime.now(), deleteUrl: imageDownloadUrl.deleteUrl);


          final updatedList = prevImages.where((e) => e!=null).cast<ImageEntity>().toList();
          updatedList.insert(0,newImageModel);
          emit(DashboardLoadedSuccessfuly(images: updatedList));




      }
    } catch (e) {
      emit(DashboardError("Resim yüklenirken hata oluştu: $e"));
    }
  }

  Future<void> fetchImages() async {

    List<ImageEntity>? previousImages ;


    if(state is DashboardLoadedSuccessfuly){
      previousImages = (state as DashboardLoadedSuccessfuly).images;
    }

    emit(DashboardLoading(previousImages: previousImages));

    try {
      final imageCloudData = await dashboardRemoteDataSource.fetchDashImages();
      final imageEntities = imageCloudData.map((e) => e.toEntity()).toList();
      emit(DashboardLoadedSuccessfuly(images: imageEntities));
    } catch (e) {
      emit(DashboardError("Resimler çekilirken hata oluştu: $e"));
    }
  }

  Future<void> deleteImage(String docId) async {
    if (state is! DashboardLoadedSuccessfuly) return;

    final currentState = state as DashboardLoadedSuccessfuly;
    final currentList = currentState.images;
    
    final imageToDelete = currentList.firstWhere(
          (img) => (img as ImageEntity).id == docId,
    ) as ImageEntity;
    
    final updatedList = currentList
        .where((img) => (img as ImageEntity).id != docId)
        .toList();
    emit(DashboardLoadedSuccessfuly(images: updatedList));

    print("show me the delete url ${imageToDelete.deleteUrl} and img doc ${docId}");

    try {
      await dashboardRemoteDataSource.deleteImage(
        docId: docId,
        deleteUrl: imageToDelete.deleteUrl,
      );
    } catch (e) {
      emit(DashboardLoadedSuccessfuly(images: currentList));
    }
  }

}
