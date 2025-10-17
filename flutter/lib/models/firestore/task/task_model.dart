// lib/models/task/task_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phonecodes/phonecodes.dart';
import 'package:pax/utils/country_util.dart';
import 'package:pax/utils/string_util.dart';

/// Represents a task in the Pax platform that users can participate in to earn rewards.
///
/// A [Task] contains all the information needed for users to understand, access, and
/// complete various activities like filling forms, checking out apps, or conducting interviews.
/// Each task is associated with rewards and managed through smart contracts on the blockchain.
///
/// Tasks are stored in Firestore and can be created from Firestore documents using
/// the [Task.fromFirestore] factory constructor.
///
/// Example:
/// ```dart
/// final task = Task(
///   id: 'task123',
///   title: 'Test our new app',
///   type: 'checkoutmobileapp',
///   rewardAmountPerParticipant: 100,
/// );
/// ```
class Task {
  /// Unique identifier for the task.
  ///
  /// This is typically the Firestore document ID.
  final String id;

  /// Optional reference to the task master (creator) who posted this task.
  ///
  /// Links to the user ID of the person or organization that created the task.
  final String? taskMasterId;

  /// The title or name of the task.
  ///
  /// This is displayed to users as the main heading for the task.
  final String? title;

  /// The type of task to be performed.
  ///
  /// Common values include:
  /// - 'checkoutwebapp': Check out a web application
  /// - 'fillaform': Fill out a form
  /// - 'checkoutmobileapp': Check out a mobile application
  /// - 'videointerview': Participate in a video interview
  /// - 'followonsocial': Follow on social media
  /// - 'general': General or unspecified task type
  ///
  /// Defaults to "General" if not specified.
  final String? type;

  /// The category this task belongs to.
  ///
  /// Used for organizing and filtering tasks. Defaults to "General" if not specified.
  final String? category;

  /// Estimated time in minutes required to complete this task.
  ///
  /// Helps users decide if they have enough time to participate.
  final int? estimatedTimeOfCompletionInMinutes;

  /// The deadline by which the task must be completed.
  ///
  /// Stored as a Firestore [Timestamp]. Tasks cannot be started or completed after this time.
  final Timestamp? deadline;

  /// The target number of participants needed for this task.
  ///
  /// Once this number is reached, the task may become unavailable.
  final int? targetNumberOfParticipants;

  /// External link associated with the task.
  ///
  /// Could be a website, form, app download link, or any URL users need to access
  /// to complete the task.
  final String? link;

  /// The difficulty level of the task.
  ///
  /// Common values might include 'easy', 'medium', 'hard', or custom difficulty indicators.
  final String? levelOfDifficulty;

  /// The blockchain smart contract address that manages this task.
  ///
  /// This contract handles reward distribution and task completion verification.
  final String? managerContractAddress;

  /// The reward amount each participant will receive for completing this task.
  ///
  /// The actual currency is determined by [rewardCurrencyId].
  final num? rewardAmountPerParticipant;

  /// The ID of the currency/token used for rewards.
  ///
  /// References a specific cryptocurrency or token that participants will receive.
  final int? rewardCurrencyId;

  /// Whether this task is currently available for participation.
  ///
  /// Tasks may become unavailable due to reaching participant limits, expiring,
  /// or being manually disabled.
  final bool? isAvailable;

  /// The timestamp when this task was created.
  final Timestamp? timeCreated;

  /// The timestamp when this task was last updated.
  final Timestamp? timeUpdated;

  /// Whether this is a test task.
  ///
  /// Test tasks are used for testing purposes and may not provide real rewards.
  final bool? isTest;

  /// Feedback or additional notes about the task.
  ///
  /// Can be used by task creators to provide extra context or updates.
  final String? feedback;

  /// Terms and conditions regarding payment for this task.
  ///
  /// Explains when and how participants will receive their rewards.
  final String? paymentTerms;

  /// Detailed instructions on how to complete the task.
  ///
  /// Step-by-step guidance for participants on what they need to do.
  final String? instructions;

  /// The target country or countries for this task.
  ///
  /// Can be:
  /// - "ALL" or null: Available to all countries
  /// - Comma-separated country codes (e.g., "US,UK,CA"): Available to specific countries
  ///
  /// Use the [targetCountries] getter to get a parsed list of [Country] objects.
  final String? targetCountry;

  /// The number of days a user must wait before they can participate in this task again.
  ///
  /// A cooldown period prevents users from repeatedly completing the same task.
  /// - 0 (default): No cooldown, users can participate multiple times immediately
  /// - Positive integer: Number of days to wait before re-participation is allowed
  final int numberOfCooldownDays;

  /// Creates a new [Task] instance.
  ///
  /// The [id] parameter is required and should be a unique identifier for the task.
  /// All other parameters are optional and will be set to their default values if not provided.
  ///
  /// Default values:
  /// - [type]: "General"
  /// - [category]: "General"
  /// - [numberOfCooldownDays]: 0
  Task({
    required this.id,
    this.taskMasterId,
    this.title,
    this.type = "General",
    this.category = "General",
    this.estimatedTimeOfCompletionInMinutes,
    this.deadline,
    this.targetNumberOfParticipants,
    this.link,
    this.levelOfDifficulty,
    this.managerContractAddress,
    this.rewardAmountPerParticipant,
    this.rewardCurrencyId,
    this.isAvailable,
    this.timeCreated,
    this.timeUpdated,
    this.isTest,
    this.feedback,
    this.paymentTerms,
    this.instructions,
    this.targetCountry,
    this.numberOfCooldownDays = 0,
  });

  /// Creates a [Task] instance from a Firestore document.
  ///
  /// This factory constructor takes a [DocumentSnapshot] and converts it into a [Task] object.
  /// The document ID is used as the task [id].
  ///
  /// If the document has no data, returns a minimal [Task] with only the [id] set.
  /// Otherwise, it maps all available fields from the document to the corresponding
  /// task properties.
  ///
  /// Default values are applied for [type] and [category] if not present in the document.
  ///
  /// Example:
  /// ```dart
  /// final docSnapshot = await FirebaseFirestore.instance
  ///     .collection('tasks')
  ///     .doc('task123')
  ///     .get();
  /// final task = Task.fromFirestore(docSnapshot);
  /// ```
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return Task(id: doc.id);
    }

    return Task(
      id: doc.id,
      taskMasterId: data['taskMasterId'],
      title: data['title'],
      type: data['type'] ?? 'general',
      category: data['category'] ?? 'general',
      estimatedTimeOfCompletionInMinutes:
          data['estimatedTimeOfCompletionInMinutes'],
      deadline: data['deadline'],
      targetNumberOfParticipants: data['targetNumberOfParticipants'],
      link: data['link'],
      levelOfDifficulty: data['levelOfDifficulty'],
      managerContractAddress: data['managerContractAddress'],
      rewardAmountPerParticipant: data['rewardAmountPerParticipant'],
      rewardCurrencyId: data['rewardCurrencyId'],
      isAvailable: data['isAvailable'],
      timeCreated: data['timeCreated'],
      timeUpdated: data['timeUpdated'],
      isTest: data['isTest'],
      feedback: data['feedback'],
      paymentTerms: StringUtil.capitalizeFirst(data['paymentTerms']),
      instructions: data['instructions'],
      targetCountry: data['targetCountry'],
      numberOfCooldownDays: data['numberOfCooldownDays'] ?? 0,
    );
  }

  /// Returns a user-friendly action text based on the task type.
  ///
  /// This getter transforms the task [type] into a more readable format for display
  /// in the user interface.
  ///
  /// Mappings:
  /// - 'checkoutwebapp' → 'Check Out Web App'
  /// - 'fillaform' → 'Fill A Form'
  /// - 'checkoutmobileapp' → 'Check Out Mobile App'
  /// - 'videointerview' → 'Do Video Interview'
  /// - 'followonsocial' → 'Follow On Social'
  /// - Other values → Returns the original type or 'General' if null
  ///
  /// Example:
  /// ```dart
  /// final task = Task(id: '1', type: 'checkoutwebapp');
  /// print(task.actionText); // Output: 'Check Out Web App'
  /// ```
  String get actionText {
    switch (type?.toLowerCase()) {
      case 'checkoutwebapp':
        return 'Check Out Web App';
      case 'fillaform':
        return 'Fill A Form';
      case 'checkoutmobileapp':
        return 'Check Out Mobile App';
      case 'videointerview':
        return 'Do Video Interview';
      case 'followonsocial':
        return 'Follow On Social';
      default:
        return type ?? 'General';
    }
  }

  /// Parses the [targetCountry] string into a list of [Country] objects.
  ///
  /// This getter provides a convenient way to work with the target countries for a task:
  /// - Returns an empty list if [targetCountry] is null or "ALL" (meaning all countries are targeted)
  /// - Otherwise, splits the comma-separated country codes and maps them to [Country] objects
  /// - Filters out any invalid country codes that couldn't be mapped
  ///
  /// Example:
  /// ```dart
  /// // Task with specific countries
  /// final task1 = Task(id: '1', targetCountry: 'US,UK,CA');
  /// print(task1.targetCountries.length); // Output: 3
  ///
  /// // Task for all countries
  /// final task2 = Task(id: '2', targetCountry: 'ALL');
  /// print(task2.targetCountries.isEmpty); // Output: true
  /// ```
  List<Country> get targetCountries {
    // If null or "ALL", return empty list (meaning all countries)
    if (targetCountry == null || targetCountry?.toUpperCase() == 'ALL') {
      return [];
    }

    // Split by comma and map to Country objects
    return targetCountry!
        .split(',')
        .map((code) => CountryUtil.getCountryByCode(code.trim()))
        .whereType<Country>() // Filter out nulls
        .toList();
  }

  /// Converts this [Task] instance to a map representation.
  ///
  /// This method serializes all task properties into a [Map<String, dynamic>] format,
  /// which is useful for:
  /// - Storing the task in Firestore
  /// - Sending the task data over network APIs
  /// - JSON serialization
  ///
  /// All fields, including null values, are included in the resulting map.
  ///
  /// Example:
  /// ```dart
  /// final task = Task(
  ///   id: 'task123',
  ///   title: 'Test our app',
  ///   type: 'checkoutmobileapp',
  /// );
  /// final map = task.toMap();
  /// // map contains: {'id': 'task123', 'title': 'Test our app', 'type': 'checkoutmobileapp', ...}
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskMasterId': taskMasterId,
      'title': title,
      'type': type,
      'category': category,
      'estimatedTimeOfCompletionInMinutes': estimatedTimeOfCompletionInMinutes,
      'deadline': deadline,
      'targetNumberOfParticipants': targetNumberOfParticipants,
      'link': link,
      'levelOfDifficulty': levelOfDifficulty,
      'managerContractAddress': managerContractAddress,
      'rewardAmountPerParticipant': rewardAmountPerParticipant,
      'rewardCurrencyId': rewardCurrencyId,
      'isAvailable': isAvailable,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
      'isTest': isTest,
      'feedback': feedback,
      'paymentTerms': paymentTerms,
      'instructions': instructions,
      'targetCountry': targetCountry,
      'numberOfCooldownDays': numberOfCooldownDays,
    };
  }
}
