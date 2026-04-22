import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainNavigationProvider = NotifierProvider<MainNavigationNotifier, int>(() {
  return MainNavigationNotifier();
});

class MainNavigationNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Default index
  }

  void setIndex(int index) {
    state = index;
  }
}
