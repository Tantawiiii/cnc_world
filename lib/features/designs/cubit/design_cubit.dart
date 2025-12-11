import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../data/models/design_models.dart';
import '../data/repositories/design_repository.dart';
import 'design_state.dart';

class DesignCubit extends Cubit<DesignState> {
  final DesignRepository _repository;

  DesignCubit(this._repository) : super(DesignInitial());

  Future<void> loadDesigns({int? page}) async {
    emit(DesignsLoading());
    try {
      final response = await _repository.getDesigns(page: page);
      emit(DesignsLoaded(response.data));
    } catch (e) {
      emit(DesignsError(e.toString()));
    }
  }

  Future<int> uploadImage(File imageFile) async {
    try {
      final response = await _repository.uploadImage(imageFile);
      return response.data.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> uploadFile(File file) async {
    try {
      final response = await _repository.uploadFile(file);
      return response.data.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addDesign(AddDesignRequest request) async {
    emit(DesignUploading());
    try {
      final response = await _repository.addDesign(request);
      emit(DesignUploaded(response.data));
      // Reload designs after adding
      await loadDesigns();
    } catch (e) {
      emit(DesignUploadError(e.toString()));
    }
  }

  Future<void> downloadDesign(Design design) async {
    emit(DesignDownloading(design.id));
    try {
      final fileUrl = design.fileUrlString;
      if (fileUrl.isEmpty) {
        throw Exception('File URL is not available');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          design.file?.name ??
          'design_${design.id}_${DateTime.now().millisecondsSinceEpoch}';
      final savePath = '${directory.path}/$fileName';

      await _repository.downloadFile(fileUrl, savePath);
      emit(DesignDownloaded(design.id, savePath));
    } catch (e) {
      emit(DesignDownloadError(design.id, e.toString()));
    }
  }
}
