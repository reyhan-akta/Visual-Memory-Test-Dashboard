import 'package:image_dashboard/features/dashboard/domain/entities/image_entity.dart';

abstract class DashboardGridState{}

class DashboardInitial extends DashboardGridState {}

class DashboardLoading extends DashboardGridState {

  final List<ImageEntity?>? previousImages;
  final String difficultyLevel;

  DashboardLoading({this.previousImages, required this.difficultyLevel});

}


class DashboardError extends DashboardGridState {
  final String message;
  DashboardError(this.message);
}

class DashboardLoadedSuccessfuly extends DashboardGridState{

  final List<ImageEntity> images;
  final String difficultyLevel;

  DashboardLoadedSuccessfuly({required this.images, required this.difficultyLevel});

}

class VideoLoading extends DashboardGridState{

}

class VideoLoadedSuccessfuly extends DashboardGridState{

}


class ErrorVideoLoading extends DashboardGridState{

  final String message;

  ErrorVideoLoading({required this.message});

}

