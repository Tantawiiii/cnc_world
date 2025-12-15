import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/seller_models.dart';
import '../data/repositories/seller_repository.dart';
import 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final SellerRepository _repository;

  SellerCubit(this._repository) : super(SellerInitial());

  Future<void> loadSellers({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      emit(SellersLoading());
    } else {
      final currentState = state;
      if (currentState is SellersLoaded) {
        emit(
          SellersLoadingMore(
            currentState.sellers,
            meta: currentState.meta,
            links: currentState.links,
            hasMore: currentState.hasMore,
          ),
        );
      } else {
        emit(SellersLoading());
      }
    }

    try {
      final response = await _repository.getSellers(page: page);
      final hasMore =
          response.meta != null &&
          response.meta!.currentPage < response.meta!.lastPage;

      if (loadMore) {
        final currentState = state;
        if (currentState is SellersLoaded) {
          final existingSellers = currentState.sellers;
          final allSellers = [...existingSellers, ...response.data];
          emit(
            SellersLoaded(
              allSellers,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        } else {
          emit(
            SellersLoaded(
              response.data,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        }
      } else {
        emit(
          SellersLoaded(
            response.data,
            meta: response.meta,
            links: response.links,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      emit(SellersError(e.toString()));
    }
  }

  Future<void> loadMoreSellers() async {
    final currentState = state;
    if (currentState is SellersLoaded && currentState.hasMore) {
      final nextPage = (currentState.meta?.currentPage ?? 1) + 1;
      await loadSellers(page: nextPage, loadMore: true);
    }
  }

  Future<void> loadSellerDetail(int id) async {
    emit(SellerDetailLoading());
    try {
      final response = await _repository.getSellerDetail(id);
      emit(SellerDetailLoaded(response.data));
    } catch (e) {
      emit(SellerDetailError(e.toString()));
    }
  }
}
