// lib/providers/task_master_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/repositories/local/task_master_repository.dart';

// Global provider for TaskMasterRepository
final taskMasterRepositoryProvider = Provider<TaskMasterRepository>((ref) {
  return TaskMasterRepository();
});

// Provider that exposes the serverWalletId
final serverWalletIdProvider = FutureProvider.family<String?, String>((
  ref,
  taskId,
) async {
  final repository = ref.watch(taskMasterRepositoryProvider);
  return await repository.fetchServerWalletId(taskId);
});

// Provider to check if a server wallet ID exists for the current task
final hasServerWalletIdProvider = Provider.family<bool, String>((ref, taskId) {
  final walletIdAsync = ref.watch(serverWalletIdProvider(taskId));
  return walletIdAsync.when(
    data: (data) => data != null && data.isNotEmpty,
    loading: () => false,
    error: (_, __) => false,
  );
});
