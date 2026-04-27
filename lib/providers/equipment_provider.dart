import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment_profile.dart';
import '../services/database_service.dart';
import '../controllers/auth_controller.dart';

final databaseServiceProvider = Provider<DatabaseService?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null ? DatabaseService(uid: user.uid) : null,
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});

final equipmentProvider = StreamNotifierProvider<EquipmentNotifier, List<EquipmentProfile>>(() {
  return EquipmentNotifier();
});

class EquipmentNotifier extends StreamNotifier<List<EquipmentProfile>> {
  @override
  Stream<List<EquipmentProfile>> build() {
    final dbService = ref.watch(databaseServiceProvider);
    if (dbService == null) {
      return Stream.value([]);
    }
    return dbService.equipmentProfiles;
  }

  Future<void> addProfile({
    required String name,
    String? stackHeight,
    String? baseBevel,
    String? sideEdge,
    String? skiModel,
    String? notes,
  }) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService == null) return;

    final newProfile = EquipmentProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      stackHeight: stackHeight,
      baseBevel: baseBevel,
      sideEdge: sideEdge,
      skiModel: skiModel,
      notes: notes,
    );
    await dbService.createEquipmentProfile(newProfile);
  }

  Future<void> updateProfile(EquipmentProfile profile) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService == null) return;

    await dbService.updateEquipmentProfile(profile);
  }

  Future<void> deleteProfile(String id) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService == null) return;

    await dbService.deleteEquipmentProfile(id);
  }
}
