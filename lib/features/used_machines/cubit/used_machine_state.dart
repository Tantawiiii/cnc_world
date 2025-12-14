import 'package:equatable/equatable.dart';
import '../data/models/used_machine_models.dart';

abstract class UsedMachineState extends Equatable {
  const UsedMachineState();

  @override
  List<Object?> get props => [];
}

class UsedMachineInitial extends UsedMachineState {}

class UsedMachinesLoading extends UsedMachineState {}

class UsedMachinesLoaded extends UsedMachineState {
  final List<UsedMachine> machines;

  const UsedMachinesLoaded(this.machines);

  @override
  List<Object?> get props => [machines];
}

class UsedMachinesError extends UsedMachineState {
  final String message;

  const UsedMachinesError(this.message);

  @override
  List<Object?> get props => [message];
}

class UsedMachineDetailLoading extends UsedMachineState {}

class UsedMachineDetailLoaded extends UsedMachineState {
  final UsedMachine machine;

  const UsedMachineDetailLoaded(this.machine);

  @override
  List<Object?> get props => [machine];
}

class UsedMachineDetailError extends UsedMachineState {
  final String message;

  const UsedMachineDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImageUploading extends UsedMachineState {
  final double progress;

  const ImageUploading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class ImageUploaded extends UsedMachineState {
  final int imageId;

  const ImageUploaded(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class ImageUploadError extends UsedMachineState {
  final String message;

  const ImageUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddingUsedMachine extends UsedMachineState {}

class UsedMachineAdded extends UsedMachineState {
  final AddUsedMachineResponse response;

  const UsedMachineAdded(this.response);

  @override
  List<Object?> get props => [response];
}

class AddUsedMachineError extends UsedMachineState {
  final String message;

  const AddUsedMachineError(this.message);

  @override
  List<Object?> get props => [message];
}
