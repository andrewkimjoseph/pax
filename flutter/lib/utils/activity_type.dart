// lib/utils/activity_type_converter.dart

import 'package:flutter/material.dart';
import 'package:pax/models/local/activity_model.dart';
import 'package:pax/theming/colors.dart';

/// A comprehensive utility class for converting and working with ActivityType enums
class ActivityTypeConverter {
  /// Private constructor to prevent instantiation
  ActivityTypeConverter._();

  /// Converts ActivityType enum to its string representation
  static String toStringRepresentation(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'task_completion';
      case ActivityType.reward:
        return 'reward';
      case ActivityType.withdrawal:
        return 'withdrawal';
    }
  }

  /// Converts string representation to ActivityType enum
  static ActivityType? fromString(String? typeStr) {
    if (typeStr == null) return null;

    switch (typeStr) {
      case 'task_completion':
        return ActivityType.taskCompletion;
      case 'reward':
        return ActivityType.reward;
      case 'withdrawal':
        return ActivityType.withdrawal;
      default:
        return null;
    }
  }

  /// Returns the display name for the activity type
  static String getDisplayName(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'Task Completion';
      case ActivityType.reward:
        return 'Reward';
      case ActivityType.withdrawal:
        return 'Withdrawal';
    }
  }

  /// Returns the singular form of the display name
  static String getSingularName(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'Task Completion';
      case ActivityType.reward:
        return 'Reward';
      case ActivityType.withdrawal:
        return 'Withdrawal';
    }
  }

  /// Returns the plural form of the display name
  static String getPluralName(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'Task Completions';
      case ActivityType.reward:
        return 'Rewards';
      case ActivityType.withdrawal:
        return 'Withdrawals';
    }
  }

  /// Returns the icon asset path for the activity type
  static String getIconPath(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'lib/assets/svgs/task_completion_icon.svg';
      case ActivityType.reward:
        return 'lib/assets/svgs/reward_icon.svg';
      case ActivityType.withdrawal:
        return 'lib/assets/svgs/withdrawal_icon.svg';
    }
  }

  /// Returns the appropriate color for the activity type
  static Color getColor(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return PaxColors.green;
      case ActivityType.reward:
        return PaxColors.orange;
      case ActivityType.withdrawal:
        return PaxColors.deepPurple;
    }
  }

  /// Returns a short description for the activity type
  static String getDescription(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'You completed a task';
      case ActivityType.reward:
        return 'You earned a reward';
      case ActivityType.withdrawal:
        return 'You withdrew funds';
    }
  }

  /// Returns the placeholder text when no activities of this type are found
  static String getEmptyMessage(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'No task completions yet';
      case ActivityType.reward:
        return 'No rewards earned yet';
      case ActivityType.withdrawal:
        return 'No withdrawals made yet';
    }
  }

  /// Returns the database collection name associated with this activity type
  static String getCollectionName(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return 'task_completions';
      case ActivityType.reward:
        return 'rewards';
      case ActivityType.withdrawal:
        return 'withdrawals';
    }
  }

  /// Returns all available activity types
  static List<ActivityType> getAllTypes() {
    return [
      ActivityType.taskCompletion,
      ActivityType.reward,
      ActivityType.withdrawal,
    ];
  }

  /// Checks if an activity type involves monetary value
  static bool hasMonetaryValue(ActivityType type) {
    return type == ActivityType.reward || type == ActivityType.withdrawal;
  }

  /// Returns the sort priority for the activity type (for sorting mixed lists)
  static int getSortPriority(ActivityType type) {
    switch (type) {
      case ActivityType.reward:
        return 1; // Highest priority
      case ActivityType.taskCompletion:
        return 2;
      case ActivityType.withdrawal:
        return 3;
      // Lowest priority
    }
  }

  /// Gets the related activity types
  static List<ActivityType> getRelatedTypes(ActivityType type) {
    switch (type) {
      case ActivityType.taskCompletion:
        return [ActivityType.reward]; // Task completions relate to rewards
      case ActivityType.reward:
        return [
          ActivityType.taskCompletion,
          ActivityType.withdrawal,
        ]; // Rewards relate to both
      case ActivityType.withdrawal:
        return [ActivityType.reward];
    }
  }
}

/// Extension method on ActivityType for easier access to conversion methods
extension ActivityTypeExtension on ActivityType {
  String get asString => ActivityTypeConverter.toStringRepresentation(this);
  String get displayName => ActivityTypeConverter.getDisplayName(this);
  String get pluralName => ActivityTypeConverter.getPluralName(this);
  String get singularName => ActivityTypeConverter.getSingularName(this);
  String get iconPath => ActivityTypeConverter.getIconPath(this);
  Color get color => ActivityTypeConverter.getColor(this);
  String get description => ActivityTypeConverter.getDescription(this);
  String get emptyMessage => ActivityTypeConverter.getEmptyMessage(this);
  String get collectionName => ActivityTypeConverter.getCollectionName(this);
  bool get hasMonetaryValue => ActivityTypeConverter.hasMonetaryValue(this);
  int get sortPriority => ActivityTypeConverter.getSortPriority(this);
  List<ActivityType> get relatedTypes =>
      ActivityTypeConverter.getRelatedTypes(this);
}

/// Extension method for List&lt;Activity&gt; to filter by type
extension ActivityListExtension on List<Activity> {
  List<Activity> filterByType(ActivityType type) {
    return where((activity) => activity.type == type).toList();
  }

  // Group activities by type
  Map<ActivityType, List<Activity>> groupByType() {
    final result = <ActivityType, List<Activity>>{};
    for (final type in ActivityTypeConverter.getAllTypes()) {
      result[type] = filterByType(type);
    }
    return result;
  }
}

/// Extension method for String to convert to ActivityType
extension StringToActivityTypeExtension on String {
  ActivityType? toActivityType() {
    return ActivityTypeConverter.fromString(this);
  }
}
