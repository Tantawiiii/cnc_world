import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: Duration.zero, // Set to zero for immediate updates during development
      ));
      
      await _remoteConfig.setDefaults(<String, dynamic>{
        'AppAllowedToWork': true,
        'MaintenanceMessage': 'التطبيق غير متاح مؤقتًا. نقوم حاليًا ببعض التحديثات والصيانة لتحسين تجربتك.',
      });

      final bool updated = await _remoteConfig.fetchAndActivate();
      print('Firebase Remote Config: Fetch and activate success: $updated');
      print('Firebase Remote Config Last Fetch Status: ${_remoteConfig.lastFetchStatus}');
    } catch (e) {
      print('Remote Config initialization error: $e');
    }
  }

  bool isAppWorking() {
    final value = _remoteConfig.getBool('AppAllowedToWork');
    print('Checking AppAllowedToWork from Remote Config: $value');
    return value;
  }

  String getMaintenanceMessage() {
    final msg = _remoteConfig.getString('MaintenanceMessage');
    print('MaintenanceMessage from Remote Config: $msg');
    return msg;
  }
}
