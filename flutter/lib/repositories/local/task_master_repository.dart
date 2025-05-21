// lib/repositories/task_master/task_master_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/repositories/firestore/tasks/tasks_repository.dart';

class TaskMasterRepository {
  final TasksRepository _tasksRepository;
  final FirebaseFirestore _firestore;

  // Default serverWalletId is null
  String? serverWalletId;

  // Constructor
  TaskMasterRepository({
    TasksRepository? tasksRepository,
    FirebaseFirestore? firestore,
  }) : _tasksRepository = tasksRepository ?? TasksRepository(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch and update the serverWalletId for a task master based on taskId
  Future<String?> fetchServerWalletId(String taskId) async {
    serverWalletId = await _tasksRepository.getTaskMasterServerWalletId(taskId);
    return serverWalletId;
  }

  // Get the current serverWalletId (returns null if not yet fetched)
  String? getServerWalletId() {
    return serverWalletId;
  }

  // Check if a serverWalletId exists for the task master
  bool hasServerWalletId() {
    return serverWalletId != null && serverWalletId!.isNotEmpty;
  }

  // Stream a specific task master's account data by their ID
  Stream<DocumentSnapshot> streamTaskMasterAccount(String taskMasterId) {
    return _firestore.collection('pax_accounts').doc(taskMasterId).snapshots();
  }

  // Get a task master's account data directly
  Future<Map<String, dynamic>?> getTaskMasterAccountData(
    String taskMasterId,
  ) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('pax_accounts').doc(taskMasterId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving task master account data: $e');
      }
      return null;
    }
  }
}
