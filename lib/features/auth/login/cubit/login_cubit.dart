import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../data/repositories/login_repository.dart';
import '../data/models/login_models.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository _repository;
  final StorageService _storageService;
  final DioClient _dioClient;

  LoginCubit()
    : _repository = LoginRepository(),
      _storageService = di.sl<StorageService>(),
      _dioClient = di.sl<DioClient>(),
      super(LoginInitial());

  Future<void> login(String phone, String password) async {
    emit(LoginLoading());

    try {
      final request = LoginRequest(phone: phone, password: password);
      final response = await _repository.login(request);

      // Save token
      await _storageService.saveToken(response.token);

      // Save user type
      await _storageService.saveUserType(response.type);

      // Save user data
      await _storageService.saveUserData(response.data.toJson());

      // Set token in dio client
      _dioClient.setAuthToken(response.token);

      emit(LoginSuccess(response));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
