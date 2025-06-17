import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeSelectedIndexNotifier extends Notifier<int> {
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

final homeSelectedIndexProvider =
    NotifierProvider<HomeSelectedIndexNotifier, int>(
      HomeSelectedIndexNotifier.new,
    );
