import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';

class RankedEquipmentList extends ConsumerWidget {
  const RankedEquipmentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    if (analytics.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Ranked Setups (Fastest First)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = analytics[index];
              final isFastest = index == 0;
              return _AnalyticsCard(item: item, index: index, isFastest: isFastest);
            },
            childCount: analytics.length,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final EquipmentAnalytics item;
  final int index;
  final bool isFastest;

  const _AnalyticsCard({
    required this.item,
    required this.index,
    required this.isFastest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isFastest ? Colors.green.withValues(alpha: 0.1) : null,
      elevation: isFastest ? 4 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isFastest ? Colors.green : Colors.blueGrey,
          child: Text('#${index + 1}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          item.equipment.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${item.runCount} total runs'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.averageTime.toStringAsFixed(2)}s',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isFastest ? Colors.green : Colors.blue,
              ),
            ),
            const Text('avg time', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
