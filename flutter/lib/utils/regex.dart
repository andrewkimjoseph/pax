final urlRegex = RegExp(
  r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-.,@?^=%&:/~+#]*)?$',
  caseSensitive: false,
);

/// Regex to remove Branch SDK special characters from parameter keys
/// Removes ~, +, $ from the beginning of strings
final branchParamCleaner = RegExp(r'^[~+$]');
