// Achievement names and amounts constants
class AchievementConstants {
  // Achievement Names
  static const String taskStarter = "Task Starter";
  static const String taskExpert = "Task Expert";
  static const String profilePerfectionist = "Profile Perfectionist";
  static const String payoutConnector = "Payout Connector";
  static const String verifiedHuman = "Verified Human";

  // Achievement Amounts
  static const int taskStarterAmount = 100;
  static const int taskExpertAmount = 1000;
  static const int profilePerfectionistAmount = 400;
  static const int payoutConnectorAmount = 500;
  static const int verifiedHumanAmount = 500;

  // Achievement Tasks Needed
  static const int taskStarterTasksNeeded = 1;
  static const int taskExpertTasksNeeded = 10;
  static const int profilePerfectionistTasksNeeded = 1;
  static const int payoutConnectorTasksNeeded = 1;
  static const int verifiedHumanTasksNeeded = 1;

  // Helper method to get amount for achievement
  static int getAmountForAchievement(String achievementName) {
    switch (achievementName) {
      case taskStarter:
        return taskStarterAmount;
      case taskExpert:
        return taskExpertAmount;
      case profilePerfectionist:
        return profilePerfectionistAmount;
      case payoutConnector:
        return payoutConnectorAmount;
      case verifiedHuman:
        return verifiedHumanAmount;
      default:
        return 0;
    }
  }

  // Helper method to get tasks needed for achievement
  static int getTasksNeededForAchievement(String achievementName) {
    switch (achievementName) {
      case taskStarter:
        return taskStarterTasksNeeded;
      case taskExpert:
        return taskExpertTasksNeeded;
      case profilePerfectionist:
        return profilePerfectionistTasksNeeded;
      case payoutConnector:
        return payoutConnectorTasksNeeded;
      case verifiedHuman:
        return verifiedHumanTasksNeeded;
      default:
        return 1;
    }
  }
}
