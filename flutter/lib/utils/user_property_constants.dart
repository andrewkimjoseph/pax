/// Constants for Firebase Analytics user properties.
/// All properties are prefixed with 'pax_' to identify them in analytics.
/// Firebase Analytics requires property names to be 1-24 alphanumeric characters.
///
/// Usage: These constants are used in analytics tracking to identify user properties
/// that will be sent to Firebase Analytics and other analytics platforms.
class UserPropertyConstants {
  // ============================================================================
  // PARTICIPANT BASIC INFORMATION
  // ============================================================================

  /// The unique identifier for the participant
  /// Value: 'pax_participant_id'
  static const String participantId = 'pax_participant_id';

  /// The display name of the participant
  /// Value: 'pax_display_name'
  static const String displayName = 'pax_display_name';

  /// The email address of the participant
  /// Value: 'pax_email_address'
  static const String emailAddress = 'pax_email_address';

  /// The phone number of the participant
  /// Value: 'pax_phone_number'
  static const String phoneNumber = 'pax_phone_number';

  /// The gender of the participant
  /// Value: 'pax_gender'
  static const String gender = 'pax_gender';

  /// The country of the participant
  /// Value: 'pax_country'
  static const String country = 'pax_country';

  /// The date of birth of the participant
  /// Value: 'pax_date_of_birth'
  static const String dateOfBirth = 'pax_date_of_birth';

  /// The URI of the participant's profile picture
  /// Value: 'pax_profile_pic_uri'
  static const String profilePictureURI = 'pax_profile_pic_uri';

  // ============================================================================
  // GOODDOLLAR IDENTITY INFORMATION
  // ============================================================================

  /// The timestamp of the last GoodDollar identity authentication
  /// Value: 'pax_gd_last_auth_time'
  static const String goodDollarIdentityTimeLastAuthenticated =
      'pax_gd_last_auth_time';

  /// The expiry date of the GoodDollar identity
  /// Value: 'pax_gd_expiry_date'
  static const String goodDollarIdentityExpiryDate = 'pax_gd_expiry_date';

  // ============================================================================
  // TIMESTAMPS
  // ============================================================================

  /// The timestamp when the participant was created
  /// Value: 'pax_time_created'
  static const String timeCreated = 'pax_time_created';

  /// The timestamp when the participant was last updated
  /// Value: 'pax_time_updated'
  static const String timeUpdated = 'pax_time_updated';

  // ============================================================================
  // WALLET INFORMATION
  // ============================================================================

  /// The MiniPay wallet address of the participant
  /// Value: 'pax_minipay_address'
  static const String miniPayWalletAddress = 'pax_minipay_address';

  /// The Privy server wallet ID
  /// Value: 'pax_server_wallet_id'
  static const String privyServerWalletId = 'pax_server_wallet_id';

  /// The Privy server wallet address
  /// Value: 'pax_server_address'
  static const String privyServerWalletAddress = 'pax_server_address';

  /// The smart account wallet address
  /// Value: 'pax_smart_account_address'
  static const String smartAccountWalletAddress = 'pax_smart_account_address';

  // ============================================================================
  // PAXACCOUNT INFORMATION
  // ============================================================================

  /// The unique identifier for the PaxAccount
  /// Value: 'pax_account_id'
  static const String paxAccountId = 'pax_account_id';

  /// The contract address of the PaxAccount
  /// Value: 'pax_account_address'
  static const String paxAccountContractAddress = 'pax_account_address';

  /// The transaction hash of the PaxAccount contract creation
  /// Value: 'pax_account_txn_hash'
  static const String paxAccountContractCreationTxnHash =
      'pax_account_txn_hash';
}
