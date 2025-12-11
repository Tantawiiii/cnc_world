part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSlidersLoaded extends HomeState {
  final List<SliderItem> sliders;

  const HomeSlidersLoaded(this.sliders);

  @override
  List<Object?> get props => [sliders];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
