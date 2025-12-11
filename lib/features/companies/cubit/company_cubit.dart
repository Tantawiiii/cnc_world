import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/company_models.dart';
import '../data/repositories/company_repository.dart';
import 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _repository;

  CompanyCubit(this._repository) : super(CompanyInitial());

  Future<void> loadCompanies() async {
    emit(CompaniesLoading());
    try {
      final response = await _repository.getCompanies();
      emit(CompaniesLoaded(response.data));
    } catch (e) {
      emit(CompaniesError(e.toString()));
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
