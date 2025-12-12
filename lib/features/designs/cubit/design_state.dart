import 'package:equatable/equatable.dart';
import '../data/models/design_models.dart';

abstract class DesignState extends Equatable {
  const DesignState();

  @override
  List<Object?> get props => [];
}

class DesignInitial extends DesignState {}

class DesignsLoading extends DesignState {}

class DesignsLoaded extends DesignState {
  final List<Design> designs;

  const DesignsLoaded(this.designs);

  @override
  List<Object?> get props => [designs];
}

class DesignsError extends DesignState {
  final String message;

  const DesignsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DesignUploading extends DesignState {}

class DesignUploaded extends DesignState {
  final Design design;

  const DesignUploaded(this.design);

  @override
  List<Object?> get props => [design];
}

class DesignUploadError extends DesignState {
  final String message;

  const DesignUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

class DesignDownloading extends DesignsLoaded {
  final int designId;

  const DesignDownloading(super.designs, this.designId);

  @override
  List<Object?> get props => [designs, designId];
}

class DesignDownloaded extends DesignsLoaded {
  final int designId;
  final String filePath;

  const DesignDownloaded(super.designs, this.designId, this.filePath);

  @override
  List<Object?> get props => [designs, designId, filePath];
}

class DesignDownloadError extends DesignsLoaded {
  final int designId;
  final String message;

  const DesignDownloadError(super.designs, this.designId, this.message);

  @override
  List<Object?> get props => [designs, designId, message];
}
