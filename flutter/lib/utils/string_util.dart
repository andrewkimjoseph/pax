/// Utility functions for string manipulation and formatting.
class StringUtil {
  /// Capitalizes the first letter of a string.
  ///
  /// Returns null if the input is null, and returns the original string if empty.
  ///
  /// Example:
  /// ```dart
  /// StringUtil.capitalizeFirst('hello'); // Returns: 'Hello'
  /// StringUtil.capitalizeFirst('HELLO'); // Returns: 'HELLO'
  /// StringUtil.capitalizeFirst(''); // Returns: ''
  /// StringUtil.capitalizeFirst(null); // Returns: null
  /// ```
  static String? capitalizeFirst(String? text) {
    if (text == null || text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
