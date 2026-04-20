import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/folder.dart';
import '../models/training_session.dart';
import '../providers/folder_provider.dart';
import '../providers/session_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/navigation_provider.dart';
import 'package:intl/intl.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(folderProvider);
    final sessionsAsync = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
      ),
      body: sessionsAsync.when(
        data: (sessions) => foldersAsync.when(
          data: (folders) {
            // Group sessions by folderId
            final Map<String, List<TrainingSession>> groupedSessions = {};
            for (var session in sessions) {
              groupedSessions.putIfAbsent(session.folderId, () => []).add(session);
            }

            // Ensure "uncategorized" is handled even if no folder exists
            final hasUncategorized = groupedSessions.containsKey('uncategorized');
            
            return ListView(
              children: [
                ...folders.map((folder) => _buildFolderTile(context, ref, folder, groupedSessions[folder.id] ?? [])),
                if (hasUncategorized)
                  _buildUncategorizedTile(context, ref, groupedSessions['uncategorized'] ?? []),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading folders: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading sessions: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewFolderDialog(context, ref),
        child: const Icon(Icons.create_new_folder),
        tooltip: 'New Folder',
      ),
    );
  }

  Widget _buildFolderTile(BuildContext context, WidgetRef ref, Folder folder, List<TrainingSession> sessions) {
    return ExpansionTile(
      leading: const Icon(Icons.folder, color: Colors.amber),
      title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${sessions.length} sessions'),
      children: sessions.map((session) => _buildSessionTile(context, ref, session)).toList(),
    );
  }

  Widget _buildUncategorizedTile(BuildContext context, WidgetRef ref, List<TrainingSession> sessions) {
    return ExpansionTile(
      leading: const Icon(Icons.folder_open, color: Colors.grey),
      title: const Text('Uncategorized', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${sessions.length} sessions'),
      children: sessions.map((session) => _buildSessionTile(context, ref, session)).toList(),
    );
  }

  Widget _buildSessionTile(BuildContext context, WidgetRef ref, TrainingSession session) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
      leading: const Icon(Icons.event_note, size: 20),
      title: Text(session.location),
      subtitle: Text('${DateFormat('MMM dd, yyyy').format(session.date)} - ${session.snowCondition}'),
      onTap: () {
        ref.read(sessionIdProvider.notifier).setSessionId(session.id);
        // Navigate to Analytics (index 3)
        ref.read(mainNavigationProvider.notifier).state = 3;
      },
      onLongPress: () => _showMoveToFolderMenu(context, ref, session),
    );
  }

  void _showNewFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Folder Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(folderProvider.notifier).addFolder(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showMoveToFolderMenu(BuildContext context, WidgetRef ref, TrainingSession session) {
    final foldersAsync = ref.read(folderProvider);
    foldersAsync.whenData((folders) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Move Session to Folder', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...folders.where((f) => f.id != session.folderId).map((folder) => ListTile(
              leading: const Icon(Icons.folder),
              title: Text(folder.name),
              onTap: () {
                ref.read(sessionProvider.notifier).moveSession(session.id, folder.id);
                Navigator.pop(context);
              },
            )),
            if (session.folderId != 'uncategorized')
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('Uncategorized'),
                onTap: () {
                  ref.read(sessionProvider.notifier).moveSession(session.id, 'uncategorized');
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
