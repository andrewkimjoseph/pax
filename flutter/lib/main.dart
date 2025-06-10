import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
import 'package:flutter/services.dart';

import 'package:pax/env/env.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
import 'package:pax/routing/service.dart';
import 'package:pax/services/app_initializer.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/theming/theme_provider.dart';
import 'package:pax/utils/version_util.dart';
import 'package:pax/widgets/app_lifecycle_handler.dart';
import 'package:pax/widgets/maintenance_dialog.dart';
import 'package:pax/widgets/update_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppInitializer().initialize();
  runApp(ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final _notificationService = NotificationService();
  String? _currentVersion;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _initializeAnalytics();
    _loadCurrentVersion();
  }

  void _initializeAnalytics() {
    final amplitudeApiKey = Env.amplitudeAPIKey;
    ref.read(analyticsProvider).initialize(amplitudeApiKey);
  }

  Future<void> _loadCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _currentVersion = info.version);
  }

  void _setupNotifications() {
    _notificationService.setupForegroundMessageHandling(_handleMessage);
    _notificationService.checkForInitialMessage(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data.containsKey('route')) {
      final route = message.data['route'];
      if (kDebugMode) print('Navigating to route from FCM: $route');
      final router = ref.read(routerProvider);
      router.push(route);
    }
  }

  void _handleDeepLink(Map<dynamic, dynamic> linkData) {
    if (kDebugMode) print('Handling deep link in App: $linkData');

    final router = ref.read(routerProvider);
    if (linkData['+clicked_branch_link'] == true) {
      String? path;
      if (linkData.containsKey('~referring_link')) {
        final url = Uri.parse(linkData['~referring_link'] as String);
        if (url.path.isNotEmpty) path = url.path;
      }

      if (path != null && path.isNotEmpty) {
        if (kDebugMode) {
          print('[:_handleDeepLink] Path from Deep Link:  $path');
        }
      } else {
        if (kDebugMode) {
          print('[:_handleDeepLink] No path from Deep Link');
        }
      }
    } else {
      if (kDebugMode) {
        print('[:_handleDeepLink] No +clicked_branch_link from Deep Link');
      }
    }
    if (kDebugMode) {
      print('[:_handleDeepLink] Navigating to home');
    }
    router.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    ref.watch(fcmInitProvider);

    return AppLifecycleHandler(
      onDeepLink: _handleDeepLink,
      child: ShadcnApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'Pax',
        theme: ref.watch(themeProvider),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: Consumer(
              builder: (context, ref, _) {
                final appVersionConfigAsync = ref.watch(
                  appVersionConfigProvider,
                );
                final maintenanceConfigAsync = ref.watch(
                  maintenanceConfigProvider,
                );

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    child ?? const CircularProgressIndicator(),
                    appVersionConfigAsync.when(
                      data: (config) {
                        if (_currentVersion == null) {
                          return const SizedBox.shrink();
                        }

                        final needsUpdate =
                            config.forceUpdate &&
                            VersionUtil.isVersionLower(
                              _currentVersion!,
                              config.minimumVersion,
                            );

                        if (needsUpdate) return const UpdateDialog();

                        return maintenanceConfigAsync.when(
                          data: (maintenanceConfig) {
                            if (!maintenanceConfig.isUnderMaintenance) {
                              return const SizedBox.shrink();
                            }

                            if (kDebugMode) {
                              print(
                                'MaintenanceDialog - Maintenance config: ${maintenanceConfig.isUnderMaintenance}',
                              );
                              return const SizedBox.shrink();
                            }

                            return const MaintenanceDialog();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
