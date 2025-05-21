// lib/views/tasks/tasks_view.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/db/tasks/task_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/screenings_provider.dart';
import 'package:pax/widgets/task_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TasksView extends ConsumerStatefulWidget {
  const TasksView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TasksView> {
  @override
  Widget build(BuildContext context) {
    final participantId = ref.watch(participantProvider).participant?.id;

    // Watch the tasks stream
    final tasksStream = ref.watch(availableTasksStreamProvider(participantId));

    final paxAccount = ref.watch(paxAccountProvider).account;

    // Get the participant ID for matching screenings

    // Watch the screenings stream
    final screeningsStream = ref.watch(participantScreeningsStreamProvider);

    // Combine tasks and screenings
    return Scaffold(
      child:
          paxAccount?.contractAddress == null
              ? const Center(
                child: Text(
                  'Connect a payment method first to see available tasks.',
                ),
              )
              : tasksStream.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks available at the moment'),
                    );
                  }

                  return screeningsStream.when(
                    data: (screenings) {
                      final screeningMap = {
                        for (var screening in screenings)
                          screening.taskId: screening,
                      };

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // Optional category filter UI

                            // Task list with matched screenings
                            for (var task in tasks)
                              TaskCard(
                                task,
                                screening: screeningMap[task.id],
                              ).withPadding(all: 8),
                          ],
                        ),
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stackTrace) => Center(
                          child: Text('Error loading screenings: $error'),
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
