import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/constants/task_timer.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;

class TaskTimer extends ConsumerStatefulWidget {
  final DateTime screeningTimeCreated;

  const TaskTimer({super.key, required this.screeningTimeCreated});

  @override
  ConsumerState<TaskTimer> createState() => _TaskTimerState();
}

class _TaskTimerState extends ConsumerState<TaskTimer> {
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final endTime = widget.screeningTimeCreated.add(
      Duration(minutes: taskTimerDurationMinutes),
    );
    final difference = endTime.difference(now);
    _remainingSeconds = difference.inSeconds.clamp(
      0,
      taskTimerDurationMinutes * 60,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          if (_remainingSeconds == 0) {
            _timer?.cancel();
          }
        }
      });
    });
  }

  Color _getTimerColor() {
    if (_remainingSeconds < 60) {
      return PaxColors.red;
    } else if (_remainingSeconds < 300) {
      // less than 5 minutes
      return PaxColors.orange;
    }
    return PaxColors.deepPurple;
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final secs = seconds % 60;
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingSeconds == 0) {
      return SizedBox.shrink();
    }
    final timerColor = _getTimerColor();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: timerColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            _remainingSeconds < 60
                ? FontAwesomeIcons.exclamation
                : FontAwesomeIcons.clock,
            size: 14,
            color: timerColor,
          ),
          SizedBox(width: 6),
          SizedBox(
            width: 58, // Fixed width to accommodate "H:MM:SS" format (e.g. 2:00:54)
            child: Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: timerColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
