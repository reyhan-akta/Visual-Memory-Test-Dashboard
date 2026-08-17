import 'package:image_dashboard/features/dashboard/domain/entities/image_entity.dart';

abstract class DashboardGridState{}

class DashboardInitial extends DashboardGridState {}

class DashboardLoading extends DashboardGridState {

  final List<ImageEntity?>? previousImages;

  DashboardLoading({this.previousImages});

}



class DashboardError extends DashboardGridState {
  final String message;
  DashboardError(this.message);
}

class DashboardLoadedSuccessfuly extends DashboardGridState{

  final List<ImageEntity> images;
  DashboardLoadedSuccessfuly({required this.images});

}
