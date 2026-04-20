import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/equipment_profile.dart';
import '../models/training_session.dart';
import '../models/training_run.dart';
import '../models/folder.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService({required this.uid});

  // --- Helper: Centralized Write Logic ---
  // This ensures we always log errors and never hang the UI indefinitely
  Future<void> _safeWrite(DocumentReference doc, Map<String, dynamic> data) async {
    try {
      debugPrint('🔥 Firebase: Attempting sync to ${doc.path}...');
      
      // We don't await the server confirmation for the UI to be responsive.
      // Firestore will sync this in the background automatically.
      doc.set(data).then((_) {
        debugPrint('✅ Firebase: Successfully synced ${doc.id}');
      }).catchError((e) {
        debugPrint('❌ Firebase Sync Error: $e');
      });
    } catch (e) {
      debugPrint('❌ Firebase Initialization Error: $e');
      rethrow;
    }
  }

  // --- Equipment Profile CRUD ---

  CollectionReference get _equipmentCollection =>
      _db.collection('users').doc(uid).collection('equipment_profiles');

  Future<void> createEquipmentProfile(EquipmentProfile profile) async {
    await _safeWrite(_equipmentCollection.doc(profile.id), profile.toMap());
  }

  Stream<List<EquipmentProfile>> get equipmentProfiles {
    return _equipmentCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              EquipmentProfile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateEquipmentProfile(EquipmentProfile profile) async {
    await _equipmentCollection.doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteEquipmentProfile(String id) async {
    await _equipmentCollection.doc(id).delete();
  }

  // --- Folder CRUD ---

  CollectionReference get _folderCollection =>
      _db.collection('users').doc(uid).collection('folders');

  Future<void> createFolder(Folder folder) async {
    await _safeWrite(_folderCollection.doc(folder.id), folder.toMap());
  }

  Stream<List<Folder>> get folders {
    return _folderCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Folder.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateFolder(Folder folder) async {
    await _folderCollection.doc(folder.id).update(folder.toMap());
  }

  Future<void> deleteFolder(String id) async {
    await _folderCollection.doc(id).delete();
  }

  // --- Training Session CRUD ---

  CollectionReference get _sessionCollection =>
      _db.collection('users').doc(uid).collection('training_sessions');

  Future<void> createTrainingSession(TrainingSession session) async {
    await _safeWrite(_sessionCollection.doc(session.id), session.toMap());
  }

  Stream<List<TrainingSession>> get trainingSessions {
    return _sessionCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              TrainingSession.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateTrainingSession(TrainingSession session) async {
    await _sessionCollection.doc(session.id).update(session.toMap());
  }

  Future<void> deleteTrainingSession(String id) async {
    await _sessionCollection.doc(id).delete();
  }

  // --- Training Run CRUD ---

  CollectionReference get _runCollection =>
      _db.collection('users').doc(uid).collection('training_runs');

  Future<void> createTrainingRun(TrainingRun run) async {
    await _safeWrite(_runCollection.doc(run.id), run.toMap());
  }

  Stream<List<TrainingRun>> get trainingRuns {
    return _runCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainingRun.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateRun(TrainingRun run) async {
    await _safeWrite(_runCollection.doc(run.id), run.toMap());
  }

  Future<void> deleteRun(String id) async {
    await _runCollection.doc(id).delete();
  }
}
