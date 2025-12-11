import 'package:equatable/equatable.dart';
import '../data/models/seller_models.dart';

abstract class SellerState extends Equatable {
  const SellerState();

  @override
  List<Object?> get props => [];
}

class SellerInitial extends SellerState {}

class SellersLoading extends SellerState {}

class SellersLoaded extends SellerState {
  final List<Seller> sellers;

  const SellersLoaded(this.sellers);

  @override
  List<Object?> get props => [sellers];
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
