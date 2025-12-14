import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/maintenance_models.dart';
import '../data/repositories/maintenance_repository.dart';
import 'maintenance_state.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final MaintenanceRepository _repository;

  MaintenanceCubit(this._repository) : super(MaintenanceInitial());

  Future<void> loadEngineers() async {
    emit(MaintenanceLoading());
    try {
      final response = await _repository.getEngineers();
      emit(EngineersLoaded(response.data));
    } catch (e) {
      emit(EngineersError(e.toString()));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    emit(const ImageUploading(progress: 0.0));
    try {
      final response = await _repository.uploadImage(
        imageFile,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          emit(ImageUploading(progress: progress));
        },
      );
      emit(ImageUploaded(response.data.id));
    } catch (e) {
      emit(ImageUploadError(e.toString()));
    }
  }

  Future<void> submitMaintenance(MaintenanceRequest request) async {
    emit(MaintenanceSubmitting());
    try {
      final response = await _repository.submitMaintenance(request);
      emit(MaintenanceSubmitted(response));
    } catch (e) {
      emit(MaintenanceSubmitError(e.toString()));
    }
  }
}
