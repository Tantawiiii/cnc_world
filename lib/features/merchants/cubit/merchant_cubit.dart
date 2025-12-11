import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/merchant_models.dart';
import '../data/repositories/merchant_repository.dart';
import 'merchant_state.dart';

class MerchantCubit extends Cubit<MerchantState> {
  final MerchantRepository _repository;

  MerchantCubit(this._repository) : super(MerchantInitial());

  Future<void> loadMerchants() async {
    emit(MerchantsLoading());
    try {
      final response = await _repository.getMerchants();
      emit(MerchantsLoaded(response.data));
    } catch (e) {
      emit(MerchantsError(e.toString()));
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
