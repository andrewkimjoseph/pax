import 'package:flutter/foundation.dart';
import 'package:pax/services/analytics/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/utils/branch_param_cleaner.dart';

/// A provider class that manages analytics events and user properties.
class AnalyticsProvider {
  final AnalyticsService _analyticsService = AnalyticsService();

  /// Initializes the analytics service with the provided API key.
  Future<void> initialize(String apiKey) async {
    await _analyticsService.initialize(apiKey);
  }

  /// Sets the user ID for analytics tracking.
  Future<void> setUserId(String participantId) async {
    await _analyticsService.setUserId(participantId);

    if (kDebugMode) {
      print('Analytics Service: Set user ID: $participantId');
    }
  }

  /// Logs an event with optional properties.
  Future<void> _logEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    await _analyticsService.logEvent(eventName, properties: properties);
  }

  /// Logs a user property.
  Future<void> identifyUser(Map<String, dynamic>? userProperties) async {
    if (userProperties == null) return;

    await _analyticsService.identifyUser(userProperties);
  }

  /// Resets the user ID and clears all user properties.
  Future<void> resetUser() async {
    await _analyticsService.resetUser();
  }

  // Event tracking methods with properties
  Future<void> onboardingSkipTapped([Map<String, dynamic>? properties]) =>
      _logEvent('onboarding_skip_tapped', properties: properties);

  Future<void> signInWithGoogleTapped([Map<String, dynamic>? properties]) =>
      _logEvent('sign_in_with_google_tapped', properties: properties);

  Future<void> signInWithGoogleComplete([
    Map<String, dynamic>? properties,
  ]) async {
    Map<String, dynamic> eventProperties =
        await BranchParamCleaner.mergeWithBranchFirstReferringParams(
          properties,
        );

    return _logEvent(
      'sign_in_with_google_complete',
      properties: eventProperties,
    );
  }

  Future<void> signInWithGoogleFailed([Map<String, dynamic>? properties]) =>
      _logEvent('sign_in_with_google_failed', properties: properties);

  Future<void> invalidTokenLogoutComplete([Map<String, dynamic>? properties]) =>
      _logEvent('invalid_token_logout_complete', properties: properties);

  Future<void> dashboardTapped([Map<String, dynamic>? properties]) =>
      _logEvent('dashboard_tapped', properties: properties);

  Future<void> tasksTapped([Map<String, dynamic>? properties]) =>
      _logEvent('tasks_tapped', properties: properties);

  Future<void> achievementsTapped([Map<String, dynamic>? properties]) =>
      _logEvent('achievements_tapped', properties: properties);

  Future<void> publishedReportTapped([Map<String, dynamic>? properties]) =>
      _logEvent('published_report_tapped', properties: properties);

  Future<void> homeWalletTapped([Map<String, dynamic>? properties]) =>
      _logEvent('home_wallet_tapped', properties: properties);

  Future<void> walletWithdrawTapped([Map<String, dynamic>? properties]) =>
      _logEvent('wallet_withdraw_tapped', properties: properties);

  Future<void> continueWithdrawTapped([Map<String, dynamic>? properties]) =>
      _logEvent('continue_withdraw_tapped', properties: properties);

  Future<void> paymentMethodTapped([Map<String, dynamic>? properties]) =>
      _logEvent('payment_method_tapped', properties: properties);

  Future<void> continueSelectWalletTapped([Map<String, dynamic>? properties]) =>
      _logEvent('continue_select_wallet_tapped', properties: properties);

  Future<void> changePaymentMethodTapped([Map<String, dynamic>? properties]) =>
      _logEvent('change_payment_method_tapped', properties: properties);

  Future<void> reviewSummaryWithdrawTapped([
    Map<String, dynamic>? properties,
  ]) => _logEvent('review_summary_withdraw_tapped', properties: properties);

  Future<void> withdrawalStarted([Map<String, dynamic>? properties]) =>
      _logEvent('withdrawal_started', properties: properties);

  Future<void> withdrawalComplete([Map<String, dynamic>? properties]) =>
      _logEvent('withdrawal_complete', properties: properties);

  Future<void> xFollowTapped([Map<String, dynamic>? properties]) =>
      _logEvent('x_follow_tapped', properties: properties);

  Future<void> taskTapped([Map<String, dynamic>? properties]) =>
      _logEvent('task_tapped', properties: properties);

  Future<void> taskLoadingComplete([Map<String, dynamic>? properties]) =>
      _logEvent('task_loading_complete', properties: properties);

  Future<void> continueWithTaskTapped([Map<String, dynamic>? properties]) =>
      _logEvent('continue_with_task_tapped', properties: properties);

  Future<void> screeningStarted([Map<String, dynamic>? properties]) =>
      _logEvent('screening_started', properties: properties);

  Future<void> screeningFailed([Map<String, dynamic>? properties]) =>
      _logEvent('screening_failed', properties: properties);

  Future<void> screeningComplete([Map<String, dynamic>? properties]) =>
      _logEvent('screening_complete', properties: properties);

  Future<void> taskCompletionComplete([Map<String, dynamic>? properties]) =>
      _logEvent('task_completion_complete', properties: properties);

  Future<void> rewardingStarted([Map<String, dynamic>? properties]) =>
      _logEvent('rewarding_started', properties: properties);

  Future<void> rewardingComplete([Map<String, dynamic>? properties]) =>
      _logEvent('rewarding_complete', properties: properties);

  Future<void> rewardingFailed([Map<String, dynamic>? properties]) =>
      _logEvent('rewarding_failed', properties: properties);

  Future<void> taskCompletionsTapped([Map<String, dynamic>? properties]) =>
      _logEvent('task_completions_tapped', properties: properties);

  Future<void> rewardsTapped([Map<String, dynamic>? properties]) =>
      _logEvent('rewards_tapped', properties: properties);

  Future<void> withdrawalsTapped([Map<String, dynamic>? properties]) =>
      _logEvent('withdrawals_tapped', properties: properties);

  Future<void> myProfileTapped([Map<String, dynamic>? properties]) =>
      _logEvent('my_profile_tapped', properties: properties);

  Future<void> saveProfileChangesTapped([Map<String, dynamic>? properties]) =>
      _logEvent('save_profile_changes_tapped', properties: properties);

  Future<void> profileUpdateComplete([Map<String, dynamic>? properties]) =>
      _logEvent('profile_update_complete', properties: properties);

  Future<void> profileUpdateFailed([Map<String, dynamic>? properties]) =>
      _logEvent('profile_update_failed', properties: properties);

  Future<void> accountAndSecurityTapped([Map<String, dynamic>? properties]) =>
      _logEvent('account_and_security_tapped', properties: properties);

  Future<void> deleteAccountTapped([Map<String, dynamic>? properties]) =>
      _logEvent('delete_account_tapped', properties: properties);

  Future<void> accountDeletionComplete([Map<String, dynamic>? properties]) =>
      _logEvent('account_deletion_complete', properties: properties);

  Future<void> paymentMethodsTapped([Map<String, dynamic>? properties]) =>
      _logEvent('payment_methods_tapped', properties: properties);

  Future<void> minipayPaymentMethodCardTapped([
    Map<String, dynamic>? properties,
  ]) => _logEvent('minipay_payment_method_card_tapped', properties: properties);

  Future<void> connectMinipayTapped([Map<String, dynamic>? properties]) =>
      _logEvent('connect_minipay_tapped', properties: properties);

  Future<void> minipayConnectionComplete([
    Map<String, dynamic>? properties,
  ]) async {
    Map<String, dynamic> eventProperties =
        await BranchParamCleaner.mergeWithBranchFirstReferringParams(
          properties,
        );

    return _logEvent(
      'minipay_connection_complete',
      properties: eventProperties,
    );
  }

  Future<void> minipayConnectionFailed([Map<String, dynamic>? properties]) =>
      _logEvent('minipay_connection_failed', properties: properties);

  Future<void> helpAndSupportTapped([Map<String, dynamic>? properties]) =>
      _logEvent('help_and_support_tapped', properties: properties);

  Future<void> faqTapped([Map<String, dynamic>? properties]) =>
      _logEvent('faq_tapped', properties: properties);

  Future<void> contactSupportTapped([Map<String, dynamic>? properties]) =>
      _logEvent('contact_support_tapped', properties: properties);

  Future<void> privacyPolicyTapped([Map<String, dynamic>? properties]) =>
      _logEvent('privacy_policy_tapped', properties: properties);

  Future<void> termsOfServiceTapped([Map<String, dynamic>? properties]) =>
      _logEvent('terms_of_service_tapped', properties: properties);

  Future<void> aboutUsTapped([Map<String, dynamic>? properties]) =>
      _logEvent('about_us_tapped', properties: properties);

  Future<void> logoutTapped([Map<String, dynamic>? properties]) =>
      _logEvent('logout_tapped', properties: properties);

  Future<void> logoutComplete([Map<String, dynamic>? properties]) =>
      _logEvent('logout_complete', properties: properties);

  Future<void> achievementCreated([Map<String, dynamic>? properties]) =>
      _logEvent('achievement_created', properties: properties);

  Future<void> achievementUpdated(Map<String, dynamic> params) =>
      _logEvent('achievement_updated', properties: params);

  Future<void> achievementComplete([Map<String, dynamic>? properties]) =>
      _logEvent('achievement_complete', properties: properties);

  Future<void> claimAchievementTapped([Map<String, dynamic>? properties]) =>
      _logEvent('claim_achievement_tapped', properties: properties);

  Future<void> claimAchievementComplete([Map<String, dynamic>? properties]) =>
      _logEvent('claim_achievement_complete', properties: properties);

  Future<void> claimAchievementFailed([Map<String, dynamic>? properties]) =>
      _logEvent('claim_achievement_failed', properties: properties);

  Future<void> okOnTaskCompleteTapped([Map<String, dynamic>? properties]) =>
      _logEvent('ok_on_task_complete_tapped', properties: properties);

  Future<void> updateNowTapped([Map<String, dynamic>? properties]) =>
      _logEvent('update_now_tapped', properties: properties);

  Future<void> okMaintenanceTapped([Map<String, dynamic>? properties]) =>
      _logEvent('ok_maintenance_tapped', properties: properties);

  Future<void> unrewardedTaskCompletionTapped(Map<String, String?> map) =>
      _logEvent('unrewarded_task_completion_tapped', properties: map);

  Future<void> claimRewardTapped(Map<String, String?> map) =>
      _logEvent('claim_reward_tapped', properties: map);
  Future<void> claimRewardComplete(Map<String, String?> map) =>
      _logEvent('claim_reward_complete', properties: map);
  Future<void> claimRewardFailed(Map<String, String?> map) =>
      _logEvent('claim_reward_failed', properties: map);

  Future<void> incompleteTaskCompletionTapped(Map<String, String?> map) =>
      _logEvent('incomplete_task_tapped', properties: map);

  Future<void> goHomeToCompleteTaskTapped(Map<String, String?> map) =>
      _logEvent('go_home_to_complete_task_tapped', properties: map);

  Future<void> refreshBalancesTapped([Map<String, dynamic>? properties]) =>
      _logEvent('refresh_balances_tapped', properties: properties);
}

final analyticsProvider = Provider<AnalyticsProvider>((ref) {
  return AnalyticsProvider();
});
