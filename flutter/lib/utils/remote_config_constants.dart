/// Constants for remote configuration keys to avoid typos and maintain consistency
class RemoteConfigKeys {
  // Feature flag keys
  /// Controls whether the wallet feature is available in the app.
  /// When false, all wallet-related functionality will be hidden.
  /// Key: 'is_wallet_available'
  static const String isWalletAvailable = 'is_wallet_available';

  /// Controls whether the achievements feature is available in the app.
  /// When false, the achievements tab and related functionality will be hidden.
  /// Key: 'are_achievements_available'
  static const String areAchievementsAvailable = 'are_achievements_available';

  /// Controls whether the tasks feature is available in the app.
  /// When false, the tasks tab and related functionality will be hidden.
  /// Key: 'are_tasks_available'
  static const String areTasksAvailable = 'are_tasks_available';

  /// Controls whether task completion tracking is available.
  /// When false, users won't be able to mark tasks as complete.
  /// Key: 'are_tasks_completions_available'
  static const String areTasksCompletionsAvailable =
      'are_tasks_completions_available';

  // App version config keys
  /// The minimum version of the app that users must have installed.
  /// Users with versions below this will be prompted to update.
  /// Key: 'minimum_version'
  static const String minimumVersion = 'minimum_version';

  /// The current latest version of the app available in stores.
  /// Used to inform users about available updates.
  /// Key: 'current_version'
  static const String currentVersion = 'current_version';

  /// Whether users should be forced to update their app.
  /// When true, users cannot use the app until they update.
  /// Key: 'force_update'
  static const String forceUpdate = 'force_update';

  /// The message shown to users when an update is available.
  /// Can include information about new features or bug fixes.
  /// Key: 'update_message'
  static const String updateMessage = 'update_message';

  /// The URL where users can download the latest version of the app.
  /// Typically points to the app store listing.
  /// Key: 'update_url'
  static const String updateUrl = 'update_url';

  // Maintenance config keys
  /// Whether the app is currently under maintenance.
  /// When true, users will see a maintenance message and may have limited functionality.
  /// Key: 'is_under_maintenance'
  static const String isUnderMaintenance = 'is_under_maintenance';

  /// The message shown to users when the app is under maintenance.
  /// Should include information about when the app will be available again.
  /// Key: 'maintenance_message'
  static const String maintenanceMessage = 'maintenance_message';

  // Remote config parameter names
  /// The name of the remote config parameter containing app version configuration.
  /// Contains all version-related settings as a JSON string.
  /// Key: 'app_version_config'
  static const String appVersionConfig = 'app_version_config';

  /// The name of the remote config parameter containing maintenance configuration.
  /// Contains maintenance status and message as a JSON string.
  /// Key: 'maintenance_config'
  static const String maintenanceConfig = 'maintenance_config';

  /// The name of the remote config parameter containing feature flags.
  /// Contains boolean flags for enabling/disabling features as a JSON string.
  /// Key: 'feature_flags'
  static const String featureFlags = 'feature_flags';
}
