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
    final participant = ref.watch(participantProvider).participant;

    // Watch the tasks stream
    final tasksStream = ref.watch(
      availableTasksStreamProvider(participant?.id),
    );

    final paxAccount = ref.watch(paxAccountProvider).account;

    // Get the participant ID for matching screenings

    // Watch the screenings stream
    final screeningsStream = ref.watch(participantScreeningsStreamProvider);

    final participantIsComplete =
        (participant?.country != null &&
            participant?.dateOfBirth != null &&
            participant?.gender != null);

    final hasPaymentMethod = paxAccount?.contractAddress != null;

    // Combine tasks and screenings
    return Scaffold(
      child:
          !hasPaymentMethod
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Please connect a payment method to see available tasks.',
                        textAlign: TextAlign.center,
                      ).withPadding(all: 16).expanded(),
                    ],
                  ),
                ],
              )
              : !participantIsComplete
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Complete your profile by adding your phone number, gender and date of birth to see your achievements.',
                        textAlign: TextAlign.center,
                      ).withPadding(all: 16).expanded(),
                    ],
                  ),
                ],
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
