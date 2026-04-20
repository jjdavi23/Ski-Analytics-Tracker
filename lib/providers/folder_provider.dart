import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/folder.dart';
import '../providers/equipment_provider.dart'; // for databaseServiceProvider

final folderProvider = StreamNotifierProvider<FolderNotifier, List<Folder>>(() {
  return FolderNotifier();
});

class FolderNotifier extends StreamNotifier<List<Folder>> {
  @override
  Stream<List<Folder>> build() {
    final dbService = ref.watch(databaseServiceProvider);
    if (dbService == null) {
      return Stream.value([]);
    }
    return dbService.folders;
  }

  Future<void> addFolder(String name) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService == null) return;

    final newFolder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    await dbService.createFolder(newFolder);
  }

  Future<void> updateFolder(Folder folder) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService == null) return;

    await dbService.updateFolder(folder);
  }

  Future<void> deleteFolder(String id) async {
    final dbService = ref.read(databaseServiceProvider);
    if (dbService == null) return;

    await dbService.deleteFolder(id);
  }
}
