import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/register_models.dart';
import '../data/repositories/register_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository _registerRepository;

  RegisterCubit()
    : _registerRepository = RegisterRepository(),
      super(RegisterInitial());

  Future<void> register(RegisterRequest request) async {
    emit(RegisterLoading());

    try {
      final response = await _registerRepository.register(request);

      if (response.status == 200) {
        emit(RegisterSuccess(response.message));
      } else {
        emit(RegisterError(response.message));
      }
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }

  Future<int?> uploadImage(File imageFile) async {
    try {
      emit(RegisterImageUploading());
      final response = await _registerRepository.uploadImage(imageFile);
      emit(RegisterInitial());
      return response.data.id;
    } catch (e) {
      emit(RegisterError(e.toString()));
      return null;
    }
  }
}
