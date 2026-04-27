import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/training_run.dart';
import '../models/equipment_profile.dart';

class RunChartWidget extends StatelessWidget {
  final List<TrainingRun> runs;
  final List<EquipmentProfile> equipment;
  final bool showByEquipment;

  const RunChartWidget({
    super.key,
    required this.runs,
    required this.equipment,
    this.showByEquipment = false,
  });

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final List<LineChartBarData> lineBarsData = [];

    if (showByEquipment) {
      // Group runs by equipment ID
      final Map<String, List<TrainingRun>> groupedRuns = {};
      for (var run in runs) {
        groupedRuns.putIfAbsent(run.equipmentProfileId, () => []).add(run);
      }

      int colorIndex = 0;
      final colors = [
        Colors.blueAccent,
        Colors.redAccent,
        Colors.greenAccent,
        Colors.orangeAccent,
        Colors.purpleAccent,
        Colors.tealAccent,
      ];

      groupedRuns.forEach((equipmentId, equipmentRuns) {
        final spots = equipmentRuns.asMap().entries.map((entry) {
          // Use the index in the original runs list or just sequence? 
          // Usually trend is better as run number in that session.
          // For comparison, let's just use the index within that equipment's sublist for simplicity, 
          // or maybe the overall run index to show when they happened.
          // Using overall index is better to see performance over the whole session.
          final overallIndex = runs.indexOf(entry.value) + 1;
          return FlSpot(overallIndex.toDouble(), entry.value.timeInSeconds);
        }).toList();

        final color = colors[colorIndex % colors.length];
        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        );
        colorIndex++;
      });
    } else {
      // Single line for all runs
      final List<FlSpot> spots = runs.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble() + 1, entry.value.timeInSeconds);
      }).toList();

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: Colors.blueAccent,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blueAccent.withValues(alpha: 0.1),
          ),
        ),
      );
    }

    // Calculate dynamic Y-axis range to prevent "flatlining"
      final List<double> allTimes = runs.map((r) => r.timeInSeconds).toList();
      final double minTime = allTimes.reduce((a, b) => a < b ? a : b);
      final double maxTime = allTimes.reduce((a, b) => a > b ? a : b);

      // Add 10% vertical padding
      final double timeRange = maxTime - minTime;
      final double verticalPadding = timeRange == 0 ? 1.0 : timeRange * 0.15;

      final double minY = (minTime - verticalPadding).clamp(0, double.infinity);
      final double maxY = maxTime + verticalPadding;

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Performance Trend',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (showByEquipment)
                    const Text(
                      'Compared by Gear',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.7,
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: _buildTitles(),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                        left: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                  lineBarsData: lineBarsData,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.blueGrey.withValues(alpha: 0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((barSpot) {
                          final runIndex = barSpot.x.toInt() - 1;
                          if (runIndex >= 0 && runIndex < runs.length) {
                             final run = runs[runIndex];
                             final equip = equipment.firstWhere(
                               (e) => e.id == run.equipmentProfileId,
                               orElse: () => EquipmentProfile(id: '', name: 'Unknown'),
                             );
                             return LineTooltipItem(
                               '${equip.name}\n${barSpot.y.toStringAsFixed(2)}s',
                               const TextStyle(color: Colors.white),
                             );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (showByEquipment) ...[
              const SizedBox(height: 8),
              _buildLegend(lineBarsData),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<LineChartBarData> barData) {
    // Unique equipment IDs in the current run set
    final activeEquipIds = runs.map((r) => r.equipmentProfileId).toSet();
    final activeEquip = equipment.where((e) => activeEquipIds.contains(e.id)).toList();

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: List.generate(activeEquip.length, (index) {
        final color = barData[index % barData.length].color;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: color),
            const SizedBox(width: 4),
            Text(activeEquip[index].name, style: const TextStyle(fontSize: 10)),
          ],
        );
      }),
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) => SideTitleWidget(
            meta: meta, 
            child: Text(
              value.toInt().toString(), 
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (double value, TitleMeta meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              value.toStringAsFixed(1), 
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }
}