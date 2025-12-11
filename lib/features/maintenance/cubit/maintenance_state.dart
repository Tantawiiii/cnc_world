import 'package:equatable/equatable.dart';
import '../data/models/maintenance_models.dart';

abstract class MaintenanceState extends Equatable {
  const MaintenanceState();

  @override
  List<Object?> get props => [];
}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {}

class EngineersLoaded extends MaintenanceState {
  final List<Engineer> engineers;

  const EngineersLoaded(this.engineers);

  @override
  List<Object?> get props => [engineers];
}

class EngineersError extends MaintenanceState {
  final String message;

  const EngineersError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImageUploading extends MaintenanceState {}

class ImageUploaded extends MaintenanceState {
  final int imageId;

  const ImageUploaded(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class ImageUploadError extends MaintenanceState {
  final String message;

  const ImageUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

class MaintenanceSubmitting extends MaintenanceState {}

class MaintenanceSubmitted extends MaintenanceState {
  final MaintenanceResponse response;

  const MaintenanceSubmitted(this.response);

  @override
  List<Object?> get props => [response];
}

class MaintenanceSubmitError extends MaintenanceState {
  final String message;

  const MaintenanceSubmitError(this.message);

  @override
  List<Object?> get props => [message];
}
