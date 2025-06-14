import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefreshTimeNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setNow() {
    state = DateTime.now();
  }

  void clear() {
    state = null;
  }
}

final refreshTimeProvider = NotifierProvider<RefreshTimeNotifier, DateTime?>(
  () => RefreshTimeNotifier(),
);
