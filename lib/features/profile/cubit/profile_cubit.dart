import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/profile_models.dart';
import '../data/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  Future<void> checkAuth() async {
    emit(ProfileLoading());
    try {
      final response = await _repository.checkAuth();
      emit(ProfileLoaded(response.data));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
