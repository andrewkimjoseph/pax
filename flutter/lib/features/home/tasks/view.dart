import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/widgets/task_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TasksView extends ConsumerStatefulWidget {
  const TasksView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TasksView> {
  String? selectedValue;
  int index = 0;

  String? screenName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: // ListView.builder inside an Expanded widget
          SingleChildScrollView(
        child: Column(
          children: [
            for (var _ in [1, 2, 3, 4, 5]) TaskCard().withPadding(all: 8),
          ],
        ),
      ),
    );
  }
}
