import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/training_run.dart';

class RunChartWidget extends StatelessWidget {
  final List<TrainingRun> runs;

  const RunChartWidget({
    super.key,
    required this.runs,
  });

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final List<FlSpot> spots = runs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble() + 1, entry.value.timeInSeconds);
    }).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: _buildTitles(),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                      left: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  lineBarsData: [
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
                        // Modern Flutter syntax for opacity
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: const LineTouchData(enabled: true),
                ),
              ),
            ),
          ],
        ),
      ),
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
            // FIXED: Use 'meta: meta' instead of 'axisSide: meta.axisSide'
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
            // FIXED: Use 'meta: meta' instead of 'axisSide: meta.axisSide'
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