
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/remote_config_service.dart';
import '../services/firebase_auth_service.dart';
import '../../features/connectivity/logic/connectivity_cubit.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Storage Service
  sl.registerLazySingleton(() => StorageService(sl<SharedPreferences>()));
  sl.registerLazySingleton(() => FirebaseAuthService());

  // Dio Client
  sl.registerLazySingleton(
    () => DioClient(
      storageService: sl<StorageService>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );

  // API Service
  sl.registerLazySingleton(() => ApiService(sl<DioClient>()));

  // Connectivity
  sl.registerLazySingleton(() => ConnectivityService());
  sl.registerFactory(() => ConnectivityCubit(sl<ConnectivityService>()));

  // Remote Config
  sl.registerLazySingleton(() => RemoteConfigService());
}
