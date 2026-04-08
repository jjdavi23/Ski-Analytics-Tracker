import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/equipment_provider.dart';
import '../../controllers/run_logger_controller.dart';

class EquipmentSelector extends ConsumerWidget {
  const EquipmentSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentProfilesAsync = ref.watch(equipmentProvider);
    final loggerState = ref.watch(runLoggerControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: equipmentProfilesAsync.when(
        skipLoadingOnRefresh: true,
        data: (profiles) {
          final bool exists =
              profiles.any((p) => p.id == loggerState.selectedEquipmentId);

          return DropdownButtonFormField<String>(
            value: exists ? loggerState.selectedEquipmentId : null,
            decoration: const InputDecoration(
              labelText: 'Select Equipment',
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(),
            ),
            items: profiles.map((profile) {
              return DropdownMenuItem(
                value: profile.id,
                child: Text(profile.name),
              );
            }).toList(),
            onChanged: (equipmentId) {
              ref
                  .read(runLoggerControllerProvider.notifier)
                  .setSelectedEquipmentId(equipmentId);
            },
          );
        },
        loading: () => const Text('Loading equipment...'),
        error: (e, st) => const Text('Error loading equipment'),
      ),
    );
  }
}
