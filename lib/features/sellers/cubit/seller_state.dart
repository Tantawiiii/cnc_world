import 'package:equatable/equatable.dart';
import '../data/models/seller_models.dart';

abstract class SellerState extends Equatable {
  const SellerState();

  @override
  List<Object?> get props => [];
}

class SellerInitial extends SellerState {}

class SellersLoading extends SellerState {}

class SellersLoadingMore extends SellersLoaded {
  const SellersLoadingMore(
    super.sellers, {
    super.meta,
    super.links,
    super.hasMore,
  });
}

class SellersLoaded extends SellerState {
  final List<Seller> sellers;
  final SellersMeta? meta;
  final SellersLinks? links;
  final bool hasMore;

  const SellersLoaded(
    this.sellers, {
    this.meta,
    this.links,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [sellers, meta, links, hasMore];
}

class SellersError extends SellerState {
  final String message;

  const SellersError(this.message);

  @override
  List<Object?> get props => [message];
}

class SellerDetailLoading extends SellerState {}

class SellerDetailLoaded extends SellerState {
  final Seller seller;

  const SellerDetailLoaded(this.seller);

  @override
  List<Object?> get props => [seller];
}

class SellerDetailError extends SellerState {
  final String message;

  const SellerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
