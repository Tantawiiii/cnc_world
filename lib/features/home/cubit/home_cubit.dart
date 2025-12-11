import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/repositories/slider_repository.dart';
import '../data/models/slider_models.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SliderRepository _sliderRepository;

  HomeCubit() : _sliderRepository = SliderRepository(), super(HomeInitial());

  Future<void> loadSliders() async {
    emit(HomeLoading());

    try {
      final response = await _sliderRepository.getSliders();
      // Filter only active sliders with valid image URLs
      final activeSliders = response.data
          .where(
            (slider) =>
                slider.active &&
                (slider.imageUrl != null && slider.imageUrl!.isNotEmpty ||
                    slider.image?.fullUrl != null),
          )
          .toList();
      emit(HomeSlidersLoaded(activeSliders));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
