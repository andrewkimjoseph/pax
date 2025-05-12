import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/auth/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authStateForRouterProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
}

// Create a provider for the router notifier
final routerNotifierProvider = Provider((ref) {
  return RouterNotifier(ref);
});
