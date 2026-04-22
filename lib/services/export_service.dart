import 'dart:io';
import 'package:csv/csv.dart'; // Ensure this import is here!
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/training_run.dart';
import '../models/equipment_profile.dart';
import '../models/training_session.dart';

class ExportService {
  static Future<void> shareCsv({
    TrainingSession? session,
    required List<TrainingRun> runs,
    required List<EquipmentProfile> equipment,
  }) async {
    // 1. Prepare data rows
    final List<List<dynamic>> rows = [
      ['Export Type', session == null ? 'All Time' : 'Single Session'],
      ['Location', session?.location ?? 'Various'],
      ['Snow Condition', session?.snowCondition ?? 'Various'],
      ['Export Date', DateTime.now().toIso8601String()],
      [], // Spacer
      ['Run #', 'Time (s)', 'Gear Name', 'Gear Description', 'Timestamp', 'Session ID'],
    ];

    // Sort runs chronologically
    final sortedRuns = List<TrainingRun>.from(runs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (int i = 0; i < sortedRuns.length; i++) {
      final run = sortedRuns[i];
      final gear = equipment.firstWhere(
        (e) => e.id == run.equipmentProfileId,
        orElse: () => EquipmentProfile(
          id: 'unknown', 
          name: 'Unknown', 
          description: 'N/A'
        ),
      );

      rows.add([
        i + 1,
        run.timeInSeconds,
        gear.name,
        gear.description,
        run.timestamp.toIso8601String(),
        run.sessionId,
      ]);
    }

    // 2. Convert to CSV string
    final String csvData = Csv().encode(rows);


    // 3. Save to temporary file
    final Directory tempDir = await getTemporaryDirectory();
    final String filePrefix = session?.id ?? 'all_time';
    final File file = File('${tempDir.path}/${filePrefix}_export.csv');
    await file.writeAsString(csvData);

    // 4. Share the file using share_plus 13.0.0
    final String shareText = session != null 
        ? 'Ski Stats: ${session.location}' 
        : 'Alpine Performance Bridge: All-Time Export';

    await Share.shareXFiles(
      [XFile(file.path)],
      text: shareText,
    );
  }
}