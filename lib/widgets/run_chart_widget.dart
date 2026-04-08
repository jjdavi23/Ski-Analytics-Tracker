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
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available for chart')),
      );
    }

    // Sort runs by time/date if available, or just use indices as "Run Number"
    // Requirement says "Time vs Run Number"
    final List<FlSpot> spots = runs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble() + 1, entry.value.timeInSeconds);
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: true),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Run Number', style: TextStyle(fontSize: 12)),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Time (s)', style: TextStyle(fontSize: 12)),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowArea: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
