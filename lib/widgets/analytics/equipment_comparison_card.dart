import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_service.dart';

class EquipmentComparisonCard extends ConsumerStatefulWidget {
  const EquipmentComparisonCard({super.key});

  @override
  ConsumerState<EquipmentComparisonCard> createState() => _EquipmentComparisonCardState();
}

class _EquipmentComparisonCardState extends ConsumerState<EquipmentComparisonCard> {
  String? _equipmentAId;
  String? _equipmentBId;

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);

    if (analytics.length < 2) {
      return const SliverToBoxAdapter(
        child: Card(
          margin: EdgeInsets.all(16.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Add at least two different gear setups to compare performance deltas.'),
          ),
        ),
      );
    }

    // Find selected analytics
    final analyticsA = _equipmentAId != null 
        ? analytics.firstWhere((a) => a.equipment.id == _equipmentAId, orElse: () => analytics[0])
        : analytics[0];
    
    final analyticsB = _equipmentBId != null 
        ? analytics.firstWhere((a) => a.equipment.id == _equipmentBId, orElse: () => analytics.length > 1 ? analytics[1] : analytics[0])
        : (analytics.length > 1 ? analytics[1] : analytics[0]);

    // Update IDs if they were null (first load)
    _equipmentAId ??= analyticsA.equipment.id;
    _equipmentBId ??= analyticsB.equipment.id;

    // Calculate session average
    final sessionAvg = analytics.fold(0.0, (sum, a) => sum + a.averageTime) / analytics.length;

    final delta60 = AnalyticsService.calculateNormalizedDelta(
      avgTimeA: analyticsA.averageTime,
      avgTimeB: analyticsB.averageTime,
      sessionAvg: sessionAvg,
    );

    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Standardized Performance Delta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Normalized to a 60-second reference run',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEquipmentDropdown(
                      label: 'Setup A',
                      value: _equipmentAId,
                      items: analytics,
                      onChanged: (val) => setState(() => _equipmentAId = val),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('vs'),
                  ),
                  Expanded(
                    child: _buildEquipmentDropdown(
                      label: 'Setup B',
                      value: _equipmentBId,
                      items: analytics,
                      onChanged: (val) => setState(() => _equipmentBId = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      '${delta60.abs().toStringAsFixed(3)}s',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: delta60 == 0 ? Colors.grey : (delta60 < 0 ? Colors.green : Colors.red),
                      ),
                    ),
                    Text(
                      delta60 == 0 
                        ? 'No difference' 
                        : (delta60 < 0 ? 'Setup A is faster' : 'Setup B is faster'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentDropdown({
    required String label,
    required String? value,
    required List<EquipmentAnalytics> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      items: items.map((a) {
        return DropdownMenuItem(
          value: a.equipment.id,
          child: Text(
            a.equipment.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
