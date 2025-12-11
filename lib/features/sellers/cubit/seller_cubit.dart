import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/seller_models.dart';
import '../data/repositories/seller_repository.dart';
import 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final SellerRepository _repository;

  SellerCubit(this._repository) : super(SellerInitial());

  Future<void> loadSellers() async {
    emit(SellersLoading());
    try {
      final response = await _repository.getSellers();
      emit(SellersLoaded(response.data));
    } catch (e) {
      emit(SellersError(e.toString()));
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
