import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/equipment_profile.dart';
import '../providers/equipment_provider.dart';
import '../providers/run_provider.dart';
import '../widgets/sync_error_widget.dart';

class EquipmentLockerScreen extends ConsumerWidget {
  const EquipmentLockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(equipmentProvider);
    final runsAsync = ref.watch(runProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Locker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (profilesAsync.isLoading && !profilesAsync.hasValue)
            const LinearProgressIndicator(),
            
          Expanded(
            child: profilesAsync.when(
              skipLoadingOnRefresh: true,
              data: (profiles) => profiles.isEmpty
                  ? const Center(child: Text('No equipment profiles yet. Add one!'))
                  : runsAsync.when(
                      data: (allRuns) => ListView.builder(
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          
                          // Calculate Stats
                          final usageRuns = allRuns.where((r) => r.equipmentProfileId == profile.id).toList();
                          final totalRuns = usageRuns.length;
                          
                          DateTime? lastUsed;
                          if (usageRuns.isNotEmpty) {
                            usageRuns.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                            lastUsed = usageRuns.first.timestamp;
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      profile.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(profile.description),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showEditProfileDialog(context, ref, profile),
                                          tooltip: 'Edit Profile',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _showDeleteConfirmationDialog(context, ref, profile),
                                          tooltip: 'Delete Profile',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Runs: $totalRuns',
                                          style: TextStyle(
                                            fontSize: 12, 
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          lastUsed != null 
                                            ? 'Last Used: ${DateFormat('MMM d, yyyy').format(lastUsed)}' 
                                            : 'Never used',
                                          style: TextStyle(
                                            fontSize: 12, 
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => const Center(child: Text('Error loading usage stats')),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: SyncErrorWidget(
                  message: 'Failed to access Locker',
                  onRetry: () => ref.invalidate(equipmentProvider),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProfileDialog(context, ref),
        tooltip: 'Add Profile',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Dialogs ---

  void _showAddProfileDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Equipment Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Profile Name (e.g., Fischer SL)'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description (e.g., Swix Blue)'),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(equipmentProvider.notifier).addProfile(
                        nameController.text,
                        descriptionController.text,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, EquipmentProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final descriptionController = TextEditingController(text: profile.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Equipment Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Profile Name'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(equipmentProvider.notifier).updateProfile(
                        profile.copyWith(
                          name: nameController.text,
                          description: descriptionController.text,
                        ),
                      );
                  Navigator.pop(context);
                  
                  // Best Practice: Check if mounted before showing SnackBar
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, EquipmentProfile profile) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Equipment?'),
          content: Text(
            'Are you sure you want to delete "${profile.name}"? This will affect historical run data for this gear.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white
              ),
              onPressed: () {
                ref.read(equipmentProvider.notifier).deleteProfile(profile.id);
                Navigator.pop(context);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile deleted')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}