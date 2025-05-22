import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/remote_config/app_version_config.dart';
import 'package:pax/services/remote_config/remote_config_service.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

final appVersionConfigProvider = FutureProvider<AppVersionConfig>((ref) async {
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  return await remoteConfigService.getAppVersionConfig();
});
