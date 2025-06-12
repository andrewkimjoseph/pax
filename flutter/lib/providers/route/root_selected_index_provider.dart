import 'package:flutter_riverpod/flutter_riverpod.dart';

class RootSelectedIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }

  void reset() {
    state = 0;
  }
}

final rootSelectedIndexProvider =
    NotifierProvider<RootSelectedIndexNotifier, int>(
      RootSelectedIndexNotifier.new,
    );
