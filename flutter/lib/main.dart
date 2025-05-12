import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/routing/service.dart';
import 'theming/theme_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(ProviderScope(child: App()));
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
