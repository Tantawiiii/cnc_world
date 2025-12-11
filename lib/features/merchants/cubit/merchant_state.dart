import 'package:equatable/equatable.dart';
import '../data/models/merchant_models.dart';

abstract class MerchantState extends Equatable {
  const MerchantState();

  @override
  List<Object?> get props => [];
}

class MerchantInitial extends MerchantState {}

class MerchantsLoading extends MerchantState {}

class MerchantsLoaded extends MerchantState {
  final List<Merchant> merchants;

  const MerchantsLoaded(this.merchants);

  @override
  List<Object?> get props => [merchants];
}

class MerchantsError extends MerchantState {
  final String message;

  const MerchantsError(this.message);

  @override
  List<Object?> get props => [message];
}

class MerchantDetailLoading extends MerchantState {}

class MerchantDetailLoaded extends MerchantState {
  final Merchant merchant;

  const MerchantDetailLoaded(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class MerchantDetailError extends MerchantState {
  final String message;

  const MerchantDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
