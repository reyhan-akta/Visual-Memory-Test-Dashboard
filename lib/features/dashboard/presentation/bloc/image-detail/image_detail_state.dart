abstract class ImageDetailState {}

/// İlk/Başlangıç durumu
class ImageDetailStateInitial extends ImageDetailState {}

/// AI prompt cevabı beklenirken gösterilen durum
class JsonResponseLoading extends ImageDetailState {}

/// AI cevabı geldiğinde veya önbellekten okunduğunda JSON'ı tutan durum
class JsonResponseLoaded extends ImageDetailState {
  final String rowJson;

  JsonResponseLoaded({required this.rowJson});
}

/// AI isteğinde veya herhangi bir adımda hata oluştuğunda tetiklenen durum
class JsonResponseError extends ImageDetailState {
  final String message;

  JsonResponseError({required this.message});
}

/// Cloud'a yükleme işlemi devam ederken tetiklenen durum (Terminaldeki JSON'ı korur)
class CloudUploadingState extends ImageDetailState {
  final String rowJson;

  CloudUploadingState({required this.rowJson});
}

/// Cloud'a yükleme başarılı bir şekilde tamamlandığında tetiklenen durum
class CloudUploadSuccessState extends ImageDetailState {
  final String rowJson;

  CloudUploadSuccessState({required this.rowJson});
}