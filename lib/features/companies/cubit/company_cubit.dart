import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/company_models.dart';
import '../data/repositories/company_repository.dart';
import 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _repository;

  CompanyCubit(this._repository) : super(CompanyInitial());

  Future<void> loadCompanies({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      emit(CompaniesLoading());
    } else {
      final currentState = state;
      if (currentState is CompaniesLoaded) {
        emit(
          CompaniesLoadingMore(
            currentState.companies,
            meta: currentState.meta,
            links: currentState.links,
            hasMore: currentState.hasMore,
          ),
        );
      } else {
        emit(CompaniesLoading());
      }
    }

    try {
      final response = await _repository.getCompanies(page: page);
      final hasMore =
          response.meta != null &&
          response.meta!.currentPage < response.meta!.lastPage;

      if (loadMore) {
        final currentState = state;
        if (currentState is CompaniesLoaded) {
          final existingCompanies = currentState.companies;
          final allCompanies = [...existingCompanies, ...response.data];
          emit(
            CompaniesLoaded(
              allCompanies,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        } else {
          emit(
            CompaniesLoaded(
              response.data,
              meta: response.meta,
              links: response.links,
              hasMore: hasMore,
            ),
          );
        }
      } else {
        emit(
          CompaniesLoaded(
            response.data,
            meta: response.meta,
            links: response.links,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      emit(CompaniesError(e.toString()));
    }
  }

  Future<void> loadMoreCompanies() async {
    final currentState = state;
    if (currentState is CompaniesLoaded && currentState.hasMore) {
      final nextPage = (currentState.meta?.currentPage ?? 1) + 1;
      await loadCompanies(page: nextPage, loadMore: true);
    }
  }

  Future<void> loadCompanyDetail(int id) async {
    emit(CompanyDetailLoading());
    try {
      final response = await _repository.getCompanyDetail(id);
      emit(CompanyDetailLoaded(response.data));
    } catch (e) {
      emit(CompanyDetailError(e.toString()));
    }
  }
}
