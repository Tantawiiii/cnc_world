import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import '../data/models/design_models.dart';
import '../data/repositories/design_repository.dart';
import 'design_state.dart';

class DesignCubit extends Cubit<DesignState> {
  final DesignRepository _repository;

  DesignCubit(this._repository) : super(DesignInitial());

  Future<void> loadDesigns({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      emit(DesignsLoading());
    } else {
      final currentState = state;
      if (currentState is DesignsLoaded) {
        emit(
          DesignsLoadingMore(
            currentState.designs,
            meta: currentState.meta,
            links: currentState.links,
            hasMore: currentState.hasMore,
          ),
        );
      } else {
        emit(DesignsLoading());
      }
    }

    try {
      final response = await _repository.getDesigns(page: page);
      final hasMore =
          response.meta != null &&
          response.meta!.currentPage < response.meta!.lastPage;

      if (loadMore) {
        final currentState = state;
        if (currentState is DesignsLoaded) {
          final existingDesigns = currentState.designs;
          final allDesigns = [...existingDesigns, ...response.data];
          emit(
            DesignsLoaded(
              allDesigns,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        } else {
          emit(
            DesignsLoaded(
              response.data,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        }
      } else {
        emit(
          DesignsLoaded(
            response.data,
            meta: response.meta,
            links: response.links,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      emit(DesignsError(e.toString()));
    }
  }

  Future<void> loadMoreDesigns() async {
    final currentState = state;
    if (currentState is DesignsLoaded && currentState.hasMore) {
      final nextPage = (currentState.meta?.currentPage ?? 1) + 1;
      await loadDesigns(page: nextPage, loadMore: true);
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
      print('DesignCubit: addDesign response received');
      print('  result: ${response.result}');
      print('  message: ${response.message}');
      print('  data: ${response.data}');
      emit(DesignUploaded(response.data));
      print('DesignCubit: DesignUploaded state emitted');
    } catch (e) {
      print('DesignCubit: addDesign error: $e');
      emit(DesignUploadError(e.toString()));
    }
  }

  Future<void> downloadDesign(Design design) async {
    final currentState = state;
    List<Design> currentDesigns = [];
    DesignsMeta? meta;
    DesignsLinks? links;
    bool hasMore = false;

    if (currentState is DesignsLoaded) {
      currentDesigns = currentState.designs;
      meta = currentState.meta;
      links = currentState.links;
      hasMore = currentState.hasMore;
    } else if (currentState is DesignDownloading) {
      currentDesigns = currentState.designs;
    } else if (currentState is DesignDownloaded) {
      currentDesigns = currentState.designs;
    } else if (currentState is DesignDownloadError) {
      currentDesigns = currentState.designs;
    }

    emit(
      DesignDownloading(
        currentDesigns,
        design.id,
        isFile: false,
        meta: meta,
        links: links,
        hasMore: hasMore,
      ),
    );
    try {
      final imageUrl = design.imageUrlString;
      if (imageUrl.isEmpty) {
        throw Exception('Image URL is not available');
      }

      if (Platform.isAndroid) {
        if (await Permission.photos.isDenied) {
          await Permission.photos.request();
        }

        if (await Permission.storage.isDenied) {
          await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        if (await Permission.photos.isDenied) {
          await Permission.photos.request();
        }
      }

      final directory =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();

      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final uri = Uri.parse(imageUrl);
      final urlFileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'design_${design.id}.png';

      final cleanFileName = urlFileName.split('?').first;
      final fileName = cleanFileName.isNotEmpty
          ? cleanFileName
          : 'design_${design.id}_${DateTime.now().millisecondsSinceEpoch}.png';

      final savePath = '${downloadsDir.path}/$fileName';

      await _repository.downloadFile(imageUrl, savePath);

      final file = File(savePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final result =
            await ImageGallerySaverPlus.saveImage(
                  Uint8List.fromList(bytes),
                  name: fileName,
                  quality: 100,
                )
                as Map<dynamic, dynamic>?;

        if (result != null &&
            result['isSuccess'] == true &&
            result['filePath'] != null) {
          final savedPath = result['filePath'] as String;
          emit(
            DesignDownloaded(
              currentDesigns,
              design.id,
              savedPath,
              isFile: false,
              meta: meta,
              links: links,
              hasMore: hasMore,
            ),
          );
        } else {
          final errorMsg =
              result?['errorMessage'] as String? ?? 'Unknown error';
          throw Exception('فشل حفظ الصورة في الـ Gallery: $errorMsg');
        }
      } else {
        throw Exception('الملف غير موجود بعد التنزيل');
      }
    } catch (e) {
      emit(
        DesignDownloadError(
          currentDesigns,
          design.id,
          e.toString(),
          isFile: false,
          meta: meta,
          links: links,
          hasMore: hasMore,
        ),
      );
    }
  }

  Future<void> downloadFile(Design design) async {
    final currentState = state;
    List<Design> currentDesigns = [];
    DesignsMeta? meta;
    DesignsLinks? links;
    bool hasMore = false;

    if (currentState is DesignsLoaded) {
      currentDesigns = currentState.designs;
      meta = currentState.meta;
      links = currentState.links;
      hasMore = currentState.hasMore;
    } else if (currentState is DesignDownloading) {
      currentDesigns = currentState.designs;
      meta = currentState.meta;
      links = currentState.links;
      hasMore = currentState.hasMore;
    } else if (currentState is DesignDownloaded) {
      currentDesigns = currentState.designs;
      meta = currentState.meta;
      links = currentState.links;
      hasMore = currentState.hasMore;
    } else if (currentState is DesignDownloadError) {
      currentDesigns = currentState.designs;
      meta = currentState.meta;
      links = currentState.links;
      hasMore = currentState.hasMore;
    }

    emit(
      DesignDownloading(
        currentDesigns,
        design.id,
        isFile: true,
        meta: meta,
        links: links,
        hasMore: hasMore,
      ),
    );
    try {
      final fileUrl = design.fileUrlString;
      if (fileUrl.isEmpty) {
        throw Exception('File URL is not available');
      }

      if (Platform.isAndroid) {
        if (await Permission.storage.isDenied) {
          await Permission.storage.request();
        }
      }

      final directory =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();

      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final uri = Uri.parse(fileUrl);
      final urlFileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'design_file_${design.id}.pdf';

      final cleanFileName = urlFileName.split('?').first;
      final fileName = cleanFileName.isNotEmpty
          ? cleanFileName
          : 'design_file_${design.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savePath = '${downloadsDir.path}/$fileName';

      await _repository.downloadFile(fileUrl, savePath);

      final file = File(savePath);
      if (await file.exists()) {
        emit(
          DesignDownloaded(
            currentDesigns,
            design.id,
            savePath,
            isFile: true,
            meta: meta,
            links: links,
            hasMore: hasMore,
          ),
        );
      } else {
        throw Exception('الملف غير موجود بعد التنزيل');
      }
    } catch (e) {
      emit(
        DesignDownloadError(
          currentDesigns,
          design.id,
          e.toString(),
          isFile: true,
          meta: meta,
          links: links,
          hasMore: hasMore,
        ),
      );
    }
  }
}
