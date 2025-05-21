// lib/providers/task_master_server_id_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/local/task_master_provider.dart';

// A notifier that stores a single server wallet ID in memory
class TaskMasterServerIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Initialize with null
    return null;
  }

  // Fetch and store the server wallet ID
  Future<String?> fetchAndStoreServerId(String taskId) async {
    final repository = ref.read(taskMasterRepositoryProvider);
    final serverId = await repository.fetchServerWalletId(taskId);

    // Update the state with the fetched ID
    state = serverId;

    return serverId;
  }

  // Clear the stored server ID
  void clearServerId() {
    state = null;
  }

  // Set a server ID directly (useful for testing or manual override)
  void setServerId(String? serverId) {
    state = serverId;
  }
}

// Provider for the task master server ID
final taskMasterServerIdProvider =
    NotifierProvider<TaskMasterServerIdNotifier, String?>(() {
      return TaskMasterServerIdNotifier();
    });

// A convenience provider that gives the current state of the server ID
final hasServerIdProvider = Provider<bool>((ref) {
  final serverId = ref.watch(taskMasterServerIdProvider);
  return serverId != null && serverId.isNotEmpty;
});
