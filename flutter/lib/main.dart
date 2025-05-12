import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/firebase_options.dart';
import 'package:pax/routing/service.dart';
import 'package:pax/widgets/app_lifecycle_handler.dart';
import 'theming/theme_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: AppLifecycleHandler(child: App())));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return ShadcnApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,
      title: 'My App',
      theme: ref.watch(themeProvider),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? CircularProgressIndicator(),
        );
      },
    );
  }
}
