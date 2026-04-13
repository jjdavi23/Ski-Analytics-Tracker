import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChartFilter {
  allRuns,
  compareByEquipment,
}

// Using a modern Notifier instead of StateProvider
final chartFilterProvider = NotifierProvider<ChartFilterNotifier, ChartFilter>(() {
  return ChartFilterNotifier();
});

class ChartFilterNotifier extends Notifier<ChartFilter> {
  @override
  ChartFilter build() {
    return ChartFilter.allRuns; // Initial state
  }

  void setFilter(ChartFilter filter) {
    state = filter;
  }
}