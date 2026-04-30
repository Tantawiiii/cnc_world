import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/engineer_repository.dart';
import 'engineer_state.dart';

class EngineerCubit extends Cubit<EngineerState> {
  final EngineerRepository _repository;

  EngineerCubit(this._repository) : super(EngineerInitial());

  Future<void> loadEngineers({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      emit(EngineersLoading());
    } else {
      final currentState = state;
      if (currentState is EngineersLoaded) {
        emit(
          EngineersLoadingMore(
            currentState.engineers,
            meta: currentState.meta,
            links: currentState.links,
            hasMore: currentState.hasMore,
          ),
        );
      } else {
        emit(EngineersLoading());
      }
    }

    try {
      final response = await _repository.getEngineers(page: page);
      final hasMore =
          response.meta != null &&
          response.meta!.currentPage < response.meta!.lastPage;

      if (loadMore) {
        final currentState = state;
        if (currentState is EngineersLoaded) {
          final allEngineers = [...currentState.engineers, ...response.data];
          emit(
            EngineersLoaded(
              allEngineers,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        } else {
          emit(
            EngineersLoaded(
              response.data,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        }
      } else {
        emit(
          EngineersLoaded(
            response.data,
            meta: response.meta,
            links: response.links,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      emit(EngineersError(e.toString()));
    }
  }

  Future<void> loadMoreEngineers() async {
    final currentState = state;
    if (currentState is EngineersLoaded && currentState.hasMore) {
      final nextPage = (currentState.meta?.currentPage ?? 1) + 1;
      await loadEngineers(page: nextPage, loadMore: true);
    }
  }

  Future<void> loadEngineerDetail(int id) async {
    emit(EngineerDetailLoading());
    try {
      final response = await _repository.getEngineerDetail(id);
      emit(EngineerDetailLoaded(response.data));
    } catch (e) {
      emit(EngineerDetailError(e.toString()));
    }
  }
}
