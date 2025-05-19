import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
import 'package:pax/providers/local/task_master_server_id_provider.dart';
import 'package:pax/widgets/other_task_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/theming/colors.dart';

class TaskView extends ConsumerStatefulWidget {
  const TaskView({super.key});

  @override
  ConsumerState<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TaskView> {
  bool isLoading = true;

  // Method to launch URLs in external apps

  @override
  Widget build(BuildContext context) {
    final currentTask = ref.watch(taskContextProvider)?.task;
    final taskMasterServerWalletId = ref.read(taskMasterServerIdProvider);
    // print(currentTask?.toMap());
    return Scaffold(
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (details) {
                  context.pop();
                },
                child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
              ),
              Spacer(),
              Text(
                "${currentTask?.id.substring(0, 8)}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],
      footers: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 16),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  // Use FormErrorBuilder for button state management
                  child: PrimaryButton(
                    onPressed: () {},
                    child: Text(
                      'Continue with task',
                      style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: PaxColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
      child: Column(
        children: [
          Container(
            height: 250, // Adjust height as needed
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/images/tasks_by_canvassing.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Divider(),
          OtherTaskCard().withPadding(all: 4),
        ],
      ),
    );
  }
}
