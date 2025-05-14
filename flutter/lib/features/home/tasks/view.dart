// lib/views/tasks/tasks_view.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/tasks/task_provider.dart';
import 'package:pax/widgets/task_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TasksView extends ConsumerStatefulWidget {
  const TasksView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TasksView> {
  String? selectedCategory;
  int index = 0;
  String? screenName;

  @override
  Widget build(BuildContext context) {
    // Watch the tasks stream
    final tasksStream = ref.watch(availableTasksStreamProvider);

    return Scaffold(
      child: tasksStream.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks available at the moment'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Optional category filter UI

                // Task list
                for (var task in tasks) TaskCard(task).withPadding(all: 8),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                Center(child: Text('Error loading tasks: $error')),
      ),
    );
  }
}
