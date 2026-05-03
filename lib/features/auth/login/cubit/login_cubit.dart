import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../data/repositories/login_repository.dart';
import '../data/models/login_models.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository _repository;
  final StorageService _storageService;
  final DioClient _dioClient;
  final FirebaseAuthService _firebaseAuthService;

  LoginCubit()
    : _repository = LoginRepository(),
      _storageService = di.sl<StorageService>(),
      _dioClient = di.sl<DioClient>(),
      _firebaseAuthService = di.sl<FirebaseAuthService>(),
      super(LoginInitial());

  Future<void> login(String phone, String password) async {
    emit(LoginLoading());

    try {
      final request = LoginRequest(phone: phone, password: password);
      final response = await _repository.login(request);

      // Save token
      await _storageService.saveToken(response.token);

      // Persist custom firebase token when backend provides one.
      final customToken = response.firebaseCustomToken;
      if (customToken != null && customToken.trim().isNotEmpty) {
        await _storageService.saveFirebaseCustomToken(customToken);
      } else {
        await _storageService.removeFirebaseCustomToken();
      }

      // Save user type
      await _storageService.saveUserType(response.type);

      // Save user data
      await _storageService.saveUserData(response.data.toJson());

      // Set token in dio client
      _dioClient.setAuthToken(response.token);

      // Ensure Firebase auth session exists for chat/firestore features.
      await _firebaseAuthService.ensureSignedIn(customToken: customToken);

      emit(LoginSuccess(response));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
