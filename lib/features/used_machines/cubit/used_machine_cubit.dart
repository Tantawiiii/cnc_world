import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/used_machine_models.dart';
import '../data/repositories/used_machine_repository.dart';
import 'used_machine_state.dart';

class UsedMachineCubit extends Cubit<UsedMachineState> {
  final UsedMachineRepository _repository;

  UsedMachineCubit(this._repository) : super(UsedMachineInitial());

  Future<void> loadUsedMachines() async {
    emit(UsedMachinesLoading());
    try {
      final response = await _repository.getUsedMachines();
      emit(UsedMachinesLoaded(response.data));
    } catch (e) {
      emit(UsedMachinesError(e.toString()));
    }
  }

  Future<void> loadUsedMachineDetail(int id) async {
    emit(UsedMachineDetailLoading());
    try {
      final response = await _repository.getUsedMachineDetail(id);
      emit(UsedMachineDetailLoaded(response.data));
    } catch (e) {
      emit(UsedMachineDetailError(e.toString()));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    emit(const ImageUploading(progress: 0.0));
    try {
      final response = await _repository.uploadImage(
        imageFile,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          // Only emit progress if less than 0.99 to avoid overriding ImageUploaded
          if (progress < 0.99) {
            emit(ImageUploading(progress: progress));
          }
        },
      );
      // Ensure we emit ImageUploaded after upload completes
      emit(ImageUploaded(response.data.id));
    } catch (e) {
      emit(ImageUploadError(e.toString()));
    }
  }

  Future<void> addUsedMachine(AddUsedMachineRequest request) async {
    emit(AddingUsedMachine());
    try {
      final response = await _repository.addUsedMachine(request);
      emit(UsedMachineAdded(response));
    } catch (e) {
      emit(AddUsedMachineError(e.toString()));
    }
  }
}
