import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors;

class MaintenanceDialog extends ConsumerWidget {
  const MaintenanceDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceConfigAsync = ref.watch(maintenanceConfigProvider);

    return maintenanceConfigAsync.when(
      data: (config) {
        if (kDebugMode) {
          print(
            'MaintenanceDialog - Config received: ${config.isUnderMaintenance}',
          );
          print('MaintenanceDialog - Message: ${config.message}');
        }

        if (!config.isUnderMaintenance) {
          if (kDebugMode) {
            print(
              'MaintenanceDialog - Not showing: isUnderMaintenance is false',
            );
          }
          return const SizedBox.shrink();
        }

        if (kDebugMode) {
          print('MaintenanceDialog - Showing maintenance dialog');
        }

        return Stack(
          children: [
            Container(color: PaxColors.black.withValues(alpha: 0.5)),
            AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/svgs/canvassing.svg',
                      height: 48,
                    ).withPadding(bottom: 16),
                    const Text(
                      'Under Maintenance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).withPadding(bottom: 16),
                    Text(
                      config.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ).withPadding(bottom: 24),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: PrimaryButton(
                        onPressed: () {
                          ref.read(analyticsProvider).okMaintenanceTapped();
                        },
                        child: const Text('OK'),
                      ),
                    ),
                  ],
                ),
              ),
            ).withAlign(Alignment.center),
          ],
        );
      },
      loading: () {
        if (kDebugMode) {
          print('MaintenanceDialog - Loading state');
        }
        return const SizedBox.shrink();
      },
      error: (error, stack) {
        if (kDebugMode) {
          print('MaintenanceDialog - Error: $error');
        }
        return const SizedBox.shrink();
      },
    );
  }
}
