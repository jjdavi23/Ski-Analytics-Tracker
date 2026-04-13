import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/training_run.dart';
import '../models/equipment_profile.dart';
import '../models/training_session.dart';

class ExportService {
  static Future<void> shareSessionCsv({
    required TrainingSession session,
    required List<TrainingRun> runs,
    required List<EquipmentProfile> equipment,
  }) async {
    // 1. Prepare data rows
    final List<List<dynamic>> rows = [
      ['Session ID', session.id],
      ['Date', session.date.toIso8601String()],
      ['Location', session.location],
      ['Snow Condition', session.snowCondition],
      [], // Spacer
      ['Run #', 'Time (s)', 'Gear Name', 'Gear Description', 'Timestamp'],
    ];

    // Sort runs chronologically for the export
    final sortedRuns = List<TrainingRun>.from(runs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (int i = 0; i < sortedRuns.length; i++) {
      final run = sortedRuns[i];
      final gear = equipment.firstWhere(
        (e) => e.id == run.equipmentProfileId,
        orElse: () => EquipmentProfile(id: 'unknown', name: 'Unknown', description: ''),
      );

      rows.add([
        i + 1,
        run.timeInSeconds,
        gear.name,
        gear.description,
        run.timestamp.toIso8601String(),
      ]);
    }

    // 2. Convert to CSV string
    final String csvData = const ListToCsvConverter().convert(rows);

    // 3. Save to temporary file
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = 'session_${session.id}_export.csv';
    final File file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvData);

    // 4. Share the file
    final String shareText = 'Ski Racing Stats: ${session.location} (${session.date.toString().substring(0, 10)})';
    await Share.shareXFiles(
      [XFile(file.path)],
      text: shareText,
    );
  }
}
