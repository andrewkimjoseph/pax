import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';

class RemoteConfigListener extends ConsumerWidget {
  final Widget child;
  const RemoteConfigListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<RemoteConfigUpdate>>(remoteConfigUpdateProvider, (
      previous,
      next,
    ) {
      if (next is AsyncData) {
        ref.invalidate(appVersionConfigProvider);
        ref.invalidate(maintenanceConfigProvider);
        ref.invalidate(featureFlagsProvider);
      }
    });
    return child;
  }
}
