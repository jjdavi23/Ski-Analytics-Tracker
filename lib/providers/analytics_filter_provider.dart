import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChartFilter {
  allRuns,
  compareByEquipment,
}

final chartFilterProvider = StateProvider<ChartFilter>((ref) => ChartFilter.allRuns);
