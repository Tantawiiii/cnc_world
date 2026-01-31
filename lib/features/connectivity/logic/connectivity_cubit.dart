import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/connectivity_service.dart';

enum ConnectivityState { initial, connected, disconnected, checking }

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  late StreamSubscription _subscription;

  ConnectivityCubit(this._connectivityService) : super(ConnectivityState.initial) {
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    _subscription = _connectivityService.connectivityStream.listen((hasConnection) {
      if (hasConnection) {
        emit(ConnectivityState.connected);
      } else {
        emit(ConnectivityState.disconnected);
      }
    });
    
    // Check initial state
    _connectivityService.hasInternet().then((hasConnection) {
      if (hasConnection) {
        emit(ConnectivityState.connected);
      } else {
        emit(ConnectivityState.disconnected);
      }
    });
  }

  Future<void> checkConnectivity() async {
    emit(ConnectivityState.checking);
    final hasConnection = await _connectivityService.hasInternet();
    if (hasConnection) {
      emit(ConnectivityState.connected);
    } else {
      emit(ConnectivityState.disconnected);
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
