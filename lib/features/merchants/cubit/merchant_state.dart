import 'package:equatable/equatable.dart';
import '../data/models/merchant_models.dart';

abstract class MerchantState extends Equatable {
  const MerchantState();

  @override
  List<Object?> get props => [];
}

class MerchantInitial extends MerchantState {}

class MerchantsLoading extends MerchantState {}

class MerchantsLoadingMore extends MerchantsLoaded {
  const MerchantsLoadingMore(
    super.merchants, {
    super.meta,
    super.links,
    super.hasMore,
  });
}

class MerchantsLoaded extends MerchantState {
  final List<Merchant> merchants;
  final MerchantsMeta? meta;
  final MerchantsLinks? links;
  final bool hasMore;

  const MerchantsLoaded(
    this.merchants, {
    this.meta,
    this.links,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [merchants, meta, links, hasMore];
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
