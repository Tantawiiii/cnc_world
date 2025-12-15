import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/merchant_models.dart';
import '../data/repositories/merchant_repository.dart';
import 'merchant_state.dart';

class MerchantCubit extends Cubit<MerchantState> {
  final MerchantRepository _repository;

  MerchantCubit(this._repository) : super(MerchantInitial());

  Future<void> loadMerchants({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      emit(MerchantsLoading());
    } else {
      final currentState = state;
      if (currentState is MerchantsLoaded) {
        emit(
          MerchantsLoadingMore(
            currentState.merchants,
            meta: currentState.meta,
            links: currentState.links,
            hasMore: currentState.hasMore,
          ),
        );
      } else {
        emit(MerchantsLoading());
      }
    }

    try {
      final response = await _repository.getMerchants(page: page);
      final hasMore =
          response.meta != null &&
          response.meta!.currentPage < response.meta!.lastPage;

      if (loadMore) {
        final currentState = state;
        if (currentState is MerchantsLoaded) {
          final existingMerchants = currentState.merchants;
          final allMerchants = [...existingMerchants, ...response.data];
          emit(
            MerchantsLoaded(
              allMerchants,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        } else {
          emit(
            MerchantsLoaded(
              response.data,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        }
      } else {
        emit(
          MerchantsLoaded(
            response.data,
            meta: response.meta,
            links: response.links,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      emit(MerchantsError(e.toString()));
    }
  }

  Future<void> loadMoreMerchants() async {
    final currentState = state;
    if (currentState is MerchantsLoaded && currentState.hasMore) {
      final nextPage = (currentState.meta?.currentPage ?? 1) + 1;
      await loadMerchants(page: nextPage, loadMore: true);
    }
  }

  Future<void> loadMerchantDetail(int id) async {
    emit(MerchantDetailLoading());
    try {
      final response = await _repository.getMerchantDetail(id);
      emit(MerchantDetailLoaded(response.data));
    } catch (e) {
      emit(MerchantDetailError(e.toString()));
    }
  }
}
