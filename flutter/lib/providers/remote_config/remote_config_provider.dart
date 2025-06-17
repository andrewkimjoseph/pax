import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/services/remote_config/remote_config_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

final remoteConfigServiceProvider = Provider((ref) => RemoteConfigService());

final appVersionConfigProvider = FutureProvider((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.getAppVersionConfig();
});

final maintenanceConfigProvider = FutureProvider((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.getMaintenanceConfig();
});

final featureFlagsProvider = FutureProvider((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.getFeatureFlags();
});

final remoteConfigUpdateProvider = StreamProvider<RemoteConfigUpdate>((ref) {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.onConfigUpdated;
});
