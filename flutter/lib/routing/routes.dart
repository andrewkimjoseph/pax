class Routes {
  // Root routes
  static const root = "/";
  static const onboarding = "${root}onboarding";
  static const home = "${root}home";
  static const activity = "${root}activity";
  static const account = "${root}account";
  static const wallet = "${root}wallet";
  static const notifications = "${root}notifications";

  // Home sub-routes
  static const dashboard = "$home/dashboard";
  static const tasks = "$home/tasks";
  static const achievements = "$home/achievements";

  // Tasks sub-routes
  static const taskDetail = "$tasks/:task-id";
  static const taskRewarded = "$taskDetail/rewarded";

  // Achievements sub-routes
  static const achievementsAll = "$achievements/all";
  static const achievementsEarned = "$achievements/earned";
  static const achievementsInProgress = "$achievements/in-progress";

  // Activity sub-routes
  static const activityAll = "$activity/all";
  static const activityTaskCompletions = "$activity/task-completions";

  // Account sub-routes
  static const profile = "$account/profile";
  static const paymentMethods = "$account/payment-methods";
  static const helpAndSupport = "$account/help-and-support";
  static const security = "$account/security";

  // Help and support sub-routes
  static const faqs = "$helpAndSupport/faqs";
  static const contactSupport = "$helpAndSupport/contact-support";

  // Wallet sub-routes
  static const withdraw = "$wallet/withdraw";
  static const connect = "$wallet/connect";

  // Withdraw sub-routes
  static const enterAmount = "$withdraw/enter-amount";
  static const selectWallet = "$enterAmount/select-wallet";
  static const withdrawComplete = "$selectWallet/complete";

  // Connect sub-routes
  static const connectPaymentMethod = "$connect/:payment-method-id";
  static const enterWalletIdentifier =
      "$connectPaymentMethod/enter-wallet-identifier";
  static const connectCompleted = "$enterWalletIdentifier/completed";

  // Notifications sub-routes
  static const notificationDetail = "$notifications/:id";
}
